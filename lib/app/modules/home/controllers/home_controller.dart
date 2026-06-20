import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/api_config.dart';
import 'dart:async';
import 'package:in_app_update/in_app_update.dart'; // For In-App Updates
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';
import '../../../../app/data/services/firebase_api.dart';
import '../../../../app/data/services/family_member_service.dart';

import '../../../../app/data/models/user.dart';
import '../../../../app/data/models/slider_model.dart';
import '../../../../app/data/models/article_model.dart';
import '../../../../app/data/models/facility_model.dart';
import '../../../../app/data/repositories/appointment_repository.dart';
import '../../../../app/data/repositories/slider_repository.dart';
import '../../../../app/data/repositories/article_repository.dart';
import '../../../../app/data/repositories/facility_repository.dart';
import '../../../../app/data/repositories/vaccination_repository.dart';
import '../../../../app/services/notification_service.dart';
import '../../../routes/app_pages.dart';

class HomeController extends GetxController {
  final _box = GetStorage();

  final _appointmentRepository = Get.find<AppointmentRepository>();
  final _sliderRepository = Get.find<SliderRepository>();
  final _articleRepository = Get.find<ArticleRepository>();
  final _facilityRepository = Get.find<FacilityRepository>();
  final _familyService = FamilyMemberService();

  final user = Rxn<User>();
  final greeting = ''.obs;
  final activeAppointments = <Map<String, dynamic>>[].obs;
  final isLoadingAppointments = false.obs;
  final sliders = <SliderModel>[].obs;
  final isLoadingSliders = false.obs;
  final articles = <ArticleModel>[].obs;
  final isLoadingArticles = false.obs;
  final facilities = <FacilityModel>[].obs;
  final isLoadingFacilities = false.obs;
  final currentTime = ''.obs;

  final headerImages = <String>[].obs;

  final tabIndex = 0.obs;

  void changeTab(int index) {
    tabIndex.value = index;
  }

  @override
  void onInit() {
    super.onInit();
    _checkForUpdate(); // Check for updates on init
    _loadUser();

    // Subscribe to topic based on user role/status
    if (Firebase.apps.isNotEmpty) {
      () async {
        try {
          await FirebaseMessaging.instance.subscribeToTopic('pasien');
          if (user.value?.noRkmMedis != null) {
            final topicName = "pasien_${user.value!.noRkmMedis.replaceAll('/', '')}";
            await FirebaseMessaging.instance.subscribeToTopic(topicName);
            print("📡 FCM: Subscribed to user topic: $topicName");
          } else {
            print("⚠️ FCM: Could not subscribe to user topic (RM is null)");
          }
        } catch (e) {
          print("⚠️ FCM: Failed to subscribe: $e");
        }
      }();
    } else {
      print("📡 FCM: Skip subscription: Firebase is not initialized");
    }

    _setGreeting();
    _updateTime();
    _fetchAppointments();
    _fetchSliders();
    _fetchArticles();
    _fetchArticles();
    _fetchFacilities();
    _initVaccinationReminders();

    // Update time every minute
    Timer.periodic(const Duration(minutes: 1), (timer) => _updateTime());
  }

  @override
  void onReady() {
    super.onReady();
    // Prompt for battery optimization to ensure rich notifications
    FirebaseApi().checkAndRequestBatteryOptimization();
  }

  Future<void> _checkForUpdate() async {
    if (kDebugMode) {
      return;
    }

    try {
      final updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (updateInfo.immediateUpdateAllowed) {
          await InAppUpdate.performImmediateUpdate();
        } else if (updateInfo.flexibleUpdateAllowed) {
          await InAppUpdate.startFlexibleUpdate().then((result) {
            if (result == AppUpdateResult.success) {
              InAppUpdate.completeFlexibleUpdate();
            }
          });
        }
      }
    } catch (e) {
      print('Error checking for update: $e');
    }
  }

  void _updateTime() {
    final now = DateTime.now();
    currentTime.value = DateFormat(
      'EEEE, MMM d, yyyy,\nHH:mm',
      'id_ID',
    ).format(now);
  }

  void _loadUser() {
    if (_box.hasData('user')) {
      final userData = _box.read('user');
      user.value = User.fromJson(userData);
      print(
        "👤 User loaded: ${user.value?.nama} (RM: ${user.value?.noRkmMedis})",
      );
    } else {
      print("👤 No user data found in storage");
    }
  }

  Future<void> refreshData() async {
    _loadUser();
    await Future.wait([
      _fetchAppointments(),
      _fetchSliders(),
      _fetchArticles(),
      _initVaccinationReminders(),
    ]);
  }

  Future<void> _initVaccinationReminders() async {
    if (user.value == null) return;

    try {
      // 1. Get User/Child Data
      // Simplified: Just use the main user or first family member logic from VaccinationController
      String noRkmMedis = user.value!.noRkmMedis;
      String tglLahir = user.value!.tglLahir;
      String childName = user.value!.nama;

      // Check family members
      try {
        final familyData = await _familyService.fetchFamilyMembers();
        if (familyData.isNotEmpty) {
          // Use first child for now (matching VaccinationController default)
          final firstChild = familyData.first;
          noRkmMedis = firstChild['no_rkm_medis'];
          tglLahir = firstChild['tgl_lahir'];
          childName = firstChild['nm_pasien'];
        }
      } catch (e) {
        // Ignore, use main user
      }

      // 2. Fetch History
      final repo = Get.put(VaccinationRepository());
      final vaccines = await repo.getVaccinationHistory(
        noRkmMedis,
        tglLahir.split(' ')[0],
      );

      // 3. Schedule
      final ns = NotificationService();
      // Ensure permissions are requested (might need to be careful not to spam dialog on startup if not needed)
      // For now, let's assume permissions are requested elsewhere or we just schedule silently if allowed.
      // await ns.requestPermissions();

      await ns.scheduleVaccinationReminders(vaccines, childName);
      print("💉 Vaccination reminders scheduled for $childName");
    } catch (e) {
      print("Error initializing vaccination reminders: $e");
    }
  }

  Future<void> _scheduleAppointmentNotifications(
    List<Map<String, dynamic>> appointments,
  ) async {
    for (var apt in appointments) {
      // Parse Date & Time
      // Priority: jadwal_enrich['jam_mulai'], Fallback: jam_reg
      final dateStr = apt['tgl_registrasi'];
      final timeStr =
          (apt['jadwal_enrich'] != null &&
              apt['jadwal_enrich']['jam_mulai'] != null)
          ? apt['jadwal_enrich']['jam_mulai']
          : apt['jam_reg'];

      if (dateStr == null || timeStr == null) continue;

      try {
        final DateTime appointmentTime = DateFormat(
          'yyyy-MM-dd HH:mm:ss',
        ).parse('$dateStr $timeStr');

        final now = DateTime.now();
        final noRawat = apt['no_rawat'].toString();

        final pasName = apt['pasien']?['nm_pasien'] ?? 'Pasien';

        // 2. Notifikasi H-1 Jam
        final hMin1 = appointmentTime.subtract(const Duration(hours: 1));
        final h1Flag = 'h1_notif_sent_$noRawat';

        if (hMin1.isAfter(now)) {
          // Normal Schedule
          final jam = timeStr.toString().substring(0, 5);
          await FirebaseApi().scheduleNotification(
            id: apt['no_rawat'].hashCode + 2,
            title: "Pengingat Jadwal Pemeriksaan",
            body:
                "Halo $pasName, mengingatkan bahwa pukul $jam Anda memiliki jadwal pemeriksaan. Klik untuk detail.",
            scheduledDate: hMin1,
            payload: jsonEncode({
              'data': {'route': '/home', 'args': apt},
            }),
          );
        } else if (now.isAfter(hMin1) &&
            now.isBefore(appointmentTime) &&
            !_box.hasData(h1Flag)) {
          // Catch-up: If app opened between H-1 and Appointment time
          final jam = timeStr.toString().substring(0, 5);
          await FirebaseApi().showSimpleNotification(
            id: apt['no_rawat'].hashCode + 20,
            title: "Pengingat Jadwal Pemeriksaan",
            body:
                "Halo $pasName, menginfokan bahwa segera pada pukul $jam Anda memiliki jadwal pemeriksaan. Klik untuk detail.",
            payload: jsonEncode({
              'data': {'route': '/home', 'args': apt},
            }),
          );
          _box.write(h1Flag, true);
        }

        // 3. Notifikasi Hari H (Pagi 05:30)
        final DateTime morningOf = DateTime(
          appointmentTime.year,
          appointmentTime.month,
          appointmentTime.day,
          5,
          30,
        );
        final day0Flag = 'day0_notif_sent_$noRawat';

        if (morningOf.isAfter(now)) {
          // Normal Schedule (Future)
          final jam = timeStr.toString().substring(0, 5);
          await FirebaseApi().scheduleNotification(
            id: apt['no_rawat'].hashCode + 3,
            title: "Jadwal Pemeriksaan Hari Ini",
            body:
                "Selamat Pagi $pasName, mengingatkan bahwa hari ini Anda memiliki jadwal pemeriksaan pukul $jam. Klik untuk detail.",
            scheduledDate: morningOf,
            payload: jsonEncode({
              'data': {'route': '/home', 'args': apt},
            }),
          );
        } else if (now.year == appointmentTime.year &&
            now.month == appointmentTime.month &&
            now.day == appointmentTime.day &&
            now.hour < 11 && // If opened before 11 AM
            now.isBefore(appointmentTime) &&
            !_box.hasData(day0Flag)) {
          // Catch-up: If missed 05:30 but opened app in the morning
          final jam = timeStr.toString().substring(0, 5);
          await FirebaseApi().showSimpleNotification(
            id: apt['no_rawat'].hashCode + 30,
            title: "Jadwal Pemeriksaan Hari Ini",
            body:
                "Selamat Pagi $pasName, mengingatkan bahwa hari ini Anda memiliki jadwal pemeriksaan pukul $jam. Klik untuk detail.",
            payload: jsonEncode({
              'data': {'route': '/home', 'args': apt},
            }),
          );
          _box.write(day0Flag, true);
        }
      } catch (e) {
        print("Error parsing date/time for notification: $e");
      }
    }
  }

  Future<void> _fetchAppointments() async {
    if (user.value == null) return;

    try {
      isLoadingAppointments.value = true;

      // 1. Fetch Family Members
      List<String> rmList = [user.value!.noRkmMedis];
      try {
        final familyData = await _familyService.fetchFamilyMembers();
        for (var member in familyData) {
          if (member['no_rkm_medis'] != null) {
            rmList.add(member['no_rkm_medis']);
          }
        }
      } catch (e) {
        print("Error fetching family members for schedule: $e");
      }

      // 2. Fetch Appointments for ALL RM numbers
      List<Map<String, dynamic>> allFetchedData = [];
      await Future.wait(
        rmList.map((rm) async {
          try {
            final response = await _appointmentRepository.getActiveAppointments(
              rm,
            );
            if (response['data'] != null) {
              allFetchedData.addAll(
                List<Map<String, dynamic>>.from(response['data']),
              );
            }
          } catch (e) {
            print('Error fetching appointments for RM $rm: $e');
          }
        }),
      );

      if (allFetchedData.isNotEmpty) {
        // Fetch Live Queue Status for TODAY'S appointments
        final todayStr = DateTime.now().toString().substring(0, 10);

        for (var i = 0; i < allFetchedData.length; i++) {
          final apt = allFetchedData[i];
          if (apt['tgl_registrasi'].toString().startsWith(todayStr)) {
            try {
              final status = await _appointmentRepository.getQueueStatus(
                apt['kd_poli'],
                apt['kd_dokter'],
                apt['no_reg'], // Sending registration number
              );
              allFetchedData[i]['current_queue'] = status['current_queue'];
              allFetchedData[i]['sisa_antrian'] =
                  status['sisa_antrian']; // Store backend's calculation
              allFetchedData[i]['total_queue'] = status['total_queue'];
            } catch (e) {
              print('Error injecting queue status: $e');
              allFetchedData[i]['current_queue'] = 0;
              allFetchedData[i]['sisa_antrian'] = 0;
            }
          } else {
            // For future appointments
            allFetchedData[i]['current_queue'] = 0;
            allFetchedData[i]['sisa_antrian'] = 0;
          }
        }

        // 3. Simple deduplication (backend might return same booking if queried multiple times)
        final seenNoRawat = <String>{};
        final uniqueData = allFetchedData.where((apt) {
          final noRawat = apt['no_rawat'].toString();
          if (seenNoRawat.contains(noRawat)) return false;
          seenNoRawat.add(noRawat);
          return true;
        }).toList();

        // 4. Sort by date & time
        uniqueData.sort((a, b) {
          try {
            final dateA = DateTime.parse(
              "${a['tgl_registrasi']} ${a['jam_reg']}",
            );
            final dateB = DateTime.parse(
              "${b['tgl_registrasi']} ${b['jam_reg']}",
            );
            return dateA.compareTo(dateB);
          } catch (e) {
            return 0;
          }
        });

        activeAppointments.assignAll(uniqueData);
        _scheduleAppointmentNotifications(activeAppointments);
        await _syncAppointmentNotifications(activeAppointments);
      } else {
        activeAppointments.clear();
        await _syncAppointmentNotifications([]);
      }
    } catch (e) {
      print('Error in _fetchAppointments: $e');
    } finally {
      isLoadingAppointments.value = false;
    }
  }

  Future<void> _syncAppointmentNotifications(List<Map<String, dynamic>> activeList) async {
    try {
      final fbApi = FirebaseApi();

      // 1. Get all pending notification requests
      final pendingRequests = await fbApi.getPendingNotificationRequests();

      // 2. Get currently active no_rawat list
      final List<String> activeIds = activeList.map((apt) => apt['no_rawat'].toString()).toList();

      // 3. Keep track of all no_rawats currently scheduled to store in _box
      final List<String> scheduledIds = [];

      for (var request in pendingRequests) {
        if (request.payload != null && request.payload!.isNotEmpty) {
          try {
            final decoded = jsonDecode(request.payload!);
            if (decoded['data'] != null &&
                decoded['data']['args'] != null &&
                decoded['data']['args']['no_rawat'] != null) {
              final String noRawat = decoded['data']['args']['no_rawat'].toString();

              if (!activeIds.contains(noRawat)) {
                // Appointment is no longer active (completed, canceled, or date passed)
                await fbApi.cancelNotification(request.id);
                print("🚫 [LOCAL NOTIF] Canceled obsolete pending notification ID: ${request.id} for no_rawat: $noRawat");
              } else {
                scheduledIds.add(noRawat);
              }
            }
          } catch (e) {
            // Not an appointment reminder payload or json error, ignore
          }
        }
      }

      // 4. Update the stored scheduled list in box
      await _box.write('scheduled_no_rawat_ids', scheduledIds.toSet().toList());
    } catch (e) {
      print("Error syncing appointment notifications: $e");
    }
  }

  void _setGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      greeting.value = 'Selamat Pagi';
    } else if (hour < 15) {
      greeting.value = 'Selamat Siang';
    } else if (hour < 18) {
      greeting.value = 'Selamat Sore';
    } else {
      greeting.value = 'Selamat Malam';
    }
  }

  Future<void> _fetchSliders() async {
    try {
      isLoadingSliders.value = true;
      final data = await _sliderRepository.getSliders();
      sliders.assignAll(data);
      if (data.isNotEmpty) {
        headerImages.assignAll(data.map((e) => e.image).toList());
      } else {
        // Fallback or empty
        headerImages.assignAll([
          'https://picsum.photos/seed/hosp1/800/600',
          'https://picsum.photos/seed/hosp2/800/600',
        ]);
      }
    } catch (e) {
      print('Error fetching sliders: $e');
    } finally {
      isLoadingSliders.value = false;
    }
  }

  Future<void> _fetchFacilities() async {
    isLoadingFacilities.value = true;
    try {
      final data = await _facilityRepository.getFacilities();
      facilities.assignAll(data);
    } catch (e) {
      print('Error fetching facilities: $e');
    } finally {
      isLoadingFacilities.value = false;
    }
  }

  Future<void> _fetchArticles() async {
    try {
      isLoadingArticles.value = true;
      final data = await _articleRepository.getArticles();
      articles.assignAll(data);
    } catch (e) {
      print('Error fetching articles: $e');
    } finally {
      isLoadingArticles.value = false;
    }
  }

  Future<void> cancelAppointment(String noRawat) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      await _appointmentRepository.cancelAppointment(noRawat);

      Get.back(); // Close loading
      Get.back(); // Close detail sheet

      Get.snackbar(
        'Berhasil',
        'Registrasi pemeriksaan berhasil dibatalkan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      await _fetchAppointments();
    } catch (e) {
      Get.back(); // Close loading
      Get.snackbar(
        'Gagal',
        e.toString().contains('message')
            ? (e as dynamic)['message']
            : 'Gagal membatalkan registrasi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void toArticleDetail(ArticleModel article) {
    Get.toNamed(Routes.ARTICLE_DETAIL, arguments: article);
  }

  Future<void> hubungiPendaftaranWA() async {
    final String message = "Halo Admin Pendaftaran, saya ingin berkonsultasi / bertanya mengenai pendaftaran pemeriksaan di RSIA Aisyiyah. Mohon bantuannya.";
    final String encodedMessage = Uri.encodeComponent(message);
    final Uri waUri = Uri.parse("${ApiConfig.waUrl}?text=$encodedMessage");

    try {
      if (!await launchUrl(waUri, mode: LaunchMode.externalApplication)) {
        Get.snackbar(
          'Gagal',
          'Tidak dapat membuka aplikasi WhatsApp',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
