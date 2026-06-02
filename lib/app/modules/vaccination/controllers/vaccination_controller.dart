import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rsiap_mobile_app/app/data/repositories/vaccination_repository.dart';
import 'package:rsiap_mobile_app/app/data/services/family_member_service.dart';
import 'package:rsiap_mobile_app/app/services/notification_service.dart';
import 'package:rsiap_mobile_app/app/modules/home/controllers/home_controller.dart';

class VaccinationController extends GetxController {
  final VaccinationRepository _repository = VaccinationRepository();
  final HomeController _homeController = Get.find<HomeController>();
  final FamilyMemberService _familyService = FamilyMemberService();

  final isLoading = false.obs;
  final familyMembers = <Map<String, dynamic>>[].obs;
  final vaccinationList = <dynamic>[].obs;
  final selectedChild = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    loadFamilyAndVaccinations();
  }

  Future<void> loadFamilyAndVaccinations() async {
    isLoading.value = true;
    try {
      final user = _homeController.user.value;
      if (user != null) {
        // 1. Add Main User (Parent/Patient)
        String tglLahirUser = user.tglLahir;
        // Ensure tgl_lahir is in YYYY-MM-DD format
        if (tglLahirUser.contains(' ')) {
          tglLahirUser = tglLahirUser.split(' ')[0];
        }

        final mainUser = {
          'no_rkm_medis': user.noRkmMedis,
          'nm_pasien': user.nama,
          'tgl_lahir': tglLahirUser,
          'hubungan': 'Diri Sendiri',
          'jk': user.jenisKelamin,
        };

        familyMembers.add(mainUser);

        // 2. Fetch Family Members
        try {
          final familyData = await _familyService.fetchFamilyMembers();
          for (var member in familyData) {
            Map<String, dynamic> data;

            // Check if data is nested inside 'keluarga' object
            if (member['keluarga'] != null && member['keluarga'] is Map) {
              data = Map<String, dynamic>.from(member['keluarga']);
              // Add 'hubungan' from parent object
              data['hubungan'] = member['hubungan'];
            } else {
              // Fallback if flat
              data = Map<String, dynamic>.from(member);
            }

            // Ensure valid tgl_lahir format (remove time if present)
            if (data['tgl_lahir'] != null &&
                data['tgl_lahir'].toString().contains(' ')) {
              data['tgl_lahir'] = data['tgl_lahir'].toString().split(' ')[0];
            }

            familyMembers.add(data);
          }
        } catch (e) {
          // Ignore family fetch error, just show main user
          print("Error fetching family: $e");
        }

        // 3. Select first child if available
        if (familyMembers.isNotEmpty) {
          selectedChild.value = familyMembers.first;
          if (selectedChild.value != null) {
            await fetchVaccinationHistory(
              selectedChild.value!['no_rkm_medis'],
              selectedChild.value!['tgl_lahir'],
            );
          }
        }
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchVaccinationHistory(
    String noRkmMedis,
    String tglLahir,
  ) async {
    isLoading.value = true;
    try {
      final data = await _repository.getVaccinationHistory(
        noRkmMedis,
        tglLahir.split(' ')[0], // Ensure YYYY-MM-DD
      );
      vaccinationList.assignAll(data);

      // Schedule notifications
      _scheduleReminders(data);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void _scheduleReminders(List<dynamic> vaccines) async {
    final NotificationService ns = NotificationService();
    // Request permissions to ensure notifications are allowed
    await ns.requestPermissions();

    final String childName = selectedChild.value?['nm_pasien'] ?? 'Si Kecil';
    ns.scheduleVaccinationReminders(vaccines, childName);
  }

  Future<void> markAsDone(
    int masterId,
    String tglPemberian,
    String? catatan,
  ) async {
    if (selectedChild.value == null) return;

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      await _repository.addVaccinationRecord(
        selectedChild.value!['no_rkm_medis'],
        masterId,
        tglPemberian,
        catatan,
      );

      Get.back(); // Close loading

      Get.snackbar(
        'Berhasil',
        'Data imunisasi berhasil disimpan',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Refresh data
      fetchVaccinationHistory(
        selectedChild.value!['no_rkm_medis'],
        selectedChild.value!['tgl_lahir'],
      );
    } catch (e) {
      Get.back(); // Close loading
      Get.snackbar(
        'Gagal',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void testNotification() async {
    final ns = NotificationService();
    // Request permission again just in case (for testing)
    await ns.requestPermissions();

    Get.snackbar(
      'Tes Notifikasi',
      'Notifikasi akan muncul dalam 5 detik...',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );

    await ns.scheduleNotification(
      id: 99999,
      title: 'Tes Notifikasi Imunisasi',
      body: 'Ini adalah contoh notifikasi pengingat imunisasi.',
      scheduledDate: DateTime.now().add(const Duration(seconds: 5)),
    );
  }
}
