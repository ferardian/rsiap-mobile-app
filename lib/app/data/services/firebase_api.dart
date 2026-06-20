import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as fln;
import 'package:get/get.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tzi;
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:rsiap_mobile_app/core/constants/api_config.dart';
import 'package:rsiap_mobile_app/app/data/services/medication_reminder_service.dart';
import 'package:rsiap_mobile_app/app/data/services/api_service.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class FirebaseApi {
  static final FirebaseApi _instance = FirebaseApi._internal();
  factory FirebaseApi() => _instance;
  FirebaseApi._internal();

  bool _isInitialized = false;

  FirebaseMessaging? get _firebaseMessaging {
    if (Firebase.apps.isEmpty) return null;
    try {
      return FirebaseMessaging.instance;
    } catch (_) {
      return null;
    }
  }
  static bool _exactAlarmDenied = false;
  final Set<String> _processingReseps = {};
  final _localNotification = fln.FlutterLocalNotificationsPlugin();
  final _androidChannel = const fln.AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications',
    importance: fln.Importance.max,
  );

  Future<void> initNotif() async {
    if (_isInitialized) return;

    final fm = _firebaseMessaging;
    if (fm == null) {
      print("⚠️ Firebase is not initialized. Skipping push notification setup.");
      await initLocalNotification();
      _isInitialized = true;
      return;
    }

    try {
      await fm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
      );

      await initPushNotification();
    } catch (e) {
      print("⚠️ Failed to request permission or init push notification: $e");
    }

    await initLocalNotification();
    _isInitialized = true;
  }

  Future initLocalNotification() async {
    tz.initializeTimeZones();
    // Use Asia/Jakarta as the local reference
    tzi.setLocalLocation(tzi.getLocation('Asia/Jakarta'));

    const iOS = fln.DarwinInitializationSettings();
    const android = fln.AndroidInitializationSettings('@mipmap/launcher_icon');
    const settings = fln.InitializationSettings(iOS: iOS, android: android);

    await _localNotification.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) {
          final message = RemoteMessage.fromMap(jsonDecode(details.payload!));
          handleMessage(message);
        }
      },
    );

    final platform = _localNotification
        .resolvePlatformSpecificImplementation<
          fln.AndroidFlutterLocalNotificationsPlugin
        >();
    if (platform != null) {
      await platform.createNotificationChannel(_androidChannel);

      // Request exact alarms permission (Android 13+)
      // This will ensure the "Alarms & Reminders" permission is triggered
      await platform.requestExactAlarmsPermission();
      print("🔔 [LOCAL NOTIF] Exact Alarms Permission Requested");
    }
  }

  Future initPushNotification() async {
    final fm = _firebaseMessaging;
    if (fm == null) return;

    await fm.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

    fm.getInitialMessage().then((initialMessage) {
      FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
      if (initialMessage != null) {
        handleMessage(initialMessage);
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("[FCM] Foreground Message Received: ${message.messageId}");
      print("[FCM] Data: ${message.data}");
      print(
        "[FCM] Notification: ${message.notification?.title} - ${message.notification?.body}",
      );

      // Handle SYNC_MEDICINE even if notification is null
      if (message.data['type'] == 'SYNC_MEDICINE') {
        print("[FCM] Handling SYNC_MEDICINE...");
        _handleMedicineSync(message);
        return;
      }

      // Handle Appointment Reminders
      if (message.data['type'] == 'APPOINTMENT_REMINDER') {
        print("📅 [FCM] RECEIVED APPOINTMENT REMINDER");
        final title = message.data['title'] ?? 'Pengingat Jadwal';
        final body = message.data['body'] ?? 'Mengingatkan jadwal pemeriksaan.';
        final imageUrl = message.data['image'];

        await showMedicationReminder(
          title: title,
          body: body,
          payload: jsonEncode(message.data),
          imageUrl: imageUrl,
          id: message.hashCode,
        );
        return;
      }

      // Allow direct reminders to fall through to local notification display
      if (message.data['type'] == 'MEDICINE_REMINDER_DIRECT') {
        print("💊 [FCM] RECEIVED DIRECT REMINDER: ${message.data['meds']}");
        final title =
            message.data['title'] ??
            message.notification?.title ??
            'Pengingat Obat';
        final body =
            message.data['body'] ??
            message.notification?.body ??
            'Waktunya minum obat.';
        final imageUrl =
            message.data['image'] ?? message.notification?.android?.imageUrl;

        await showMedicationReminder(
          title: title,
          body: body,
          payload: jsonEncode(message.data),
          imageUrl: imageUrl,
          id: message.hashCode,
        );
        return;
      }

      final notification = message.notification;
      if (notification == null) {
        print(
          "⚠️ [FCM] Received message with NULL notification. Data: ${message.data}",
        );
        return;
      }

      _localNotification.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: fln.NotificationDetails(
          android: fln.AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            importance: _androidChannel.importance,
            icon: "@mipmap/launcher_icon",
            styleInformation: fln.BigTextStyleInformation(
              notification.body ?? '',
              contentTitle: notification.title,
            ),
          ),
        ),
        payload: jsonEncode(message.toMap()),
      );
    });
  }

  // Extracted helper for both foreground and background handling if needed
  // But for now, let's keep background handling in its top-level function
  // and use this for foreground.
  Future<void> _handleMedicineSync(RemoteMessage message) async {
    final noResep = message.data['no_resep'];
    if (noResep != null) {
      if (_processingReseps.contains(noResep)) {
        print("[SYNC] Already processing resep: $noResep. Skipping duplicate.");
        return;
      }

      final box = GetStorage();
      final token = box.read('token');
      if (token == null) {
        print(
          "❌ [SYNC] FAILED: Token is null. Sync requires authenticated session.",
        );
        return;
      }

      _processingReseps.add(noResep);

      try {
        // 1. Show the sync status notification IMMEDIATELY (Instant feedback)
        print("[SYNC] Showing instant notification for $noResep");
        await showSimpleNotification(
          id: noResep.hashCode.abs(),
          title: "Sinkronisasi Jadwal Obat",
          body: "Resep #$noResep sedang diproses ke jadwal harian Anda.",
          payload: jsonEncode({"no_resep": noResep}),
        );

        final apiService = Get.find<ApiService>();
        final entrypointUrl = 'farmasi/resep/$noResep';
        print("[SYNC] Requesting: ${ApiConfig.baseUrl}$entrypointUrl");

        final response = await apiService.client.get(
          entrypointUrl,
          options: Options(receiveTimeout: const Duration(seconds: 30)),
        );
        print(
          "[SYNC] Response: ${response.statusCode} - ${response.data['success']}",
        );

        if (response.data['success'] == true) {
          // 2. Schedule reminders (heavy task) - offload
          final prescription = response.data['data'];
          Future.microtask(() async {
            try {
              final int count = await MedicationReminderService()
                  .scheduleReminders(prescription);

              await showSimpleNotification(
                id: noResep.hashCode.abs() + 1,
                title: "Jadwal Obat Tersimpan 💊",
                body:
                    "$count pengingat obat berhasil disematkan ke jadwal harian Anda.",
                payload: jsonEncode({"no_resep": noResep}),
              );

              print("[SYNC] Reminders scheduled successfully for $noResep");
            } catch (e) {
              print("❌ [SYNC] Error fetching prescription: $e");
            } finally {
              _processingReseps.remove(noResep);
            }
          });
        } else {
          print("❌ Foreground: Sync failed - ${response.data['message']}");
        }
      } catch (e, stack) {
        if (e is DioException && e.response?.statusCode == 401) {
          print(
            "❌ [SYNC] AUTH ERROR (401): Token might be expired or invalid. Please re-login.",
          );
        } else {
          print("🚨 CRITICAL ERROR in foreground sync: $e");
          print(stack);
        }
      } finally {
        _processingReseps.remove(noResep);
      }
    }
  }

  Future<void> showSimpleNotification({
    required String title,
    required String body,
    required String payload,
    int id = 0,
  }) async {
    final androidDetails = fln.AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications',
      importance: fln.Importance.max,
      priority: fln.Priority.high,
      icon: '@mipmap/launcher_icon',
      largeIcon: fln.DrawableResourceAndroidBitmap('launcher_icon'),
      styleInformation: fln.BigTextStyleInformation(body, contentTitle: title),
    );

    final notificationDetails = fln.NotificationDetails(
      android: androidDetails,
    );

    print("📲 Calling _localNotification.show for: $title");
    try {
      await _localNotification.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
        payload: payload,
      );
      print("🎯 _localNotification.show CALLED SUCCESSFULLY");
    } catch (e) {
      print("❌ _localNotification.show FAILED: $e");
    }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String payload,
    fln.AndroidScheduleMode scheduleMode =
        fln.AndroidScheduleMode.exactAllowWhileIdle,
  }) async {
    final androidDetails = fln.AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications',
      importance: fln.Importance.max,
      priority: fln.Priority.high,
      icon: '@mipmap/launcher_icon',
      largeIcon: fln.DrawableResourceAndroidBitmap('app_logo'),
      styleInformation: fln.BigTextStyleInformation(body, contentTitle: title),
    );

    final notificationDetails = fln.NotificationDetails(
      android: androidDetails,
    );

    final effectiveScheduleMode = _exactAlarmDenied
        ? fln.AndroidScheduleMode.inexactAllowWhileIdle
        : scheduleMode;

    try {
      final tzScheduledDate = tzi.TZDateTime.from(scheduledDate, tzi.local);

      await _localNotification.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tzScheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: effectiveScheduleMode,
        payload: payload,
      );
      print("✅ [LOCAL NOTIF] Scheduled SUCCESSFULLY for $scheduledDate");
    } catch (e) {
      if (e.toString().contains('exact_alarms_not_permitted')) {
        _exactAlarmDenied = true;
        print(
          "⚠️ Exact alarms permission denied. Switching to Inexact mode globally.",
        );
        final tzScheduledDateInexact = tzi.TZDateTime.from(
          scheduledDate,
          tzi.local,
        );
        await _localNotification.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: tzScheduledDateInexact,
          notificationDetails: notificationDetails,
          androidScheduleMode: fln.AndroidScheduleMode.inexactAllowWhileIdle,
          payload: payload,
        );
        print("✅ [LOCAL NOTIF] Scheduled SUCCESS (Inexact) for $scheduledDate");
      } else {
        rethrow;
      }
    }
  }

  void handleMessage(RemoteMessage message) {
    if (message.data['route'] != null) {
      // Navigate using GetX
      Get.toNamed(message.data['route']);
    }
  }

  Future<void> checkAndRequestBatteryOptimization() async {
    if (!Platform.isAndroid) return;

    final status = await Permission.ignoreBatteryOptimizations.status;
    if (!status.isGranted) {
      Get.dialog(
        AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.battery_saver, color: Colors.orange),
              const SizedBox(width: 10),
              Text(
                'Optimasi Baterai',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Agar pengingat minum obat muncul tepat waktu dengan foto obat, mohon berikan izin background.',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 18,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pilih "Jangan Optimalkan" atau "Unrestricted" di menu berikutnya.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[800],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Nanti Saja',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Get.back();
                // This will open the settings page directly
                await Permission.ignoreBatteryOptimizations.request();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Izinkan Sekarang'),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    }
  }

  Future<void> logoutCleanup() async {
    try {
      // 1. Cancel all scheduled local notifications
      await _localNotification.cancelAll();
      print("[FCM] All local notifications cancelled.");

      final fm = _firebaseMessaging;
      if (fm != null) {
        // 2. Unsubscribe from general patient topic
        await fm.unsubscribeFromTopic('pasien');

        // 3. Unsubscribe from specific patient topic if user data exists
        final box = GetStorage();
        final user = box.read('user');
        if (user != null && user['no_rkm_medis'] != null) {
          final rkm = user['no_rkm_medis'].toString().replaceAll('/', '');
          final topicName = "pasien_$rkm";
          await fm.unsubscribeFromTopic(topicName);
          print("[FCM] Unsubscribed from topic: $topicName");
        }
      } else {
        print("[FCM] Skip unsubscribe: Firebase not initialized");
      }
    } catch (e) {
      print("[FCM] Error during logout cleanup: $e");
    }
  }

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final response = await Dio().get(
      url,
      options: Options(responseType: ResponseType.bytes),
    );
    final File file = File(filePath);
    await file.writeAsBytes(response.data);
    return filePath;
  }

  Future<void> showMedicationReminder({
    required String title,
    required String body,
    required String payload,
    String? imageUrl,
    int id = 0,
  }) async {
    // Default style information
    fln.StyleInformation styleInformation = fln.BigTextStyleInformation(
      body,
      contentTitle: title,
    );

    // Default large icon (launcher icon)
    fln.AndroidBitmap<Object> largeIcon =
        const fln.DrawableResourceAndroidBitmap('app_logo');

    // If image URL is provided, try to download and use it as Large Icon
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final String largeIconPath = await _downloadAndSaveFile(
          imageUrl,
          'large_icon_$id',
        );
        largeIcon = fln.FilePathAndroidBitmap(largeIconPath);
      } catch (e) {
        print("❌ [LOCAL NOTIF] Failed to download large icon: $e");
      }
    }

    final androidDetails = fln.AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications',
      importance: fln.Importance.max,
      priority: fln.Priority.high,
      icon: '@mipmap/launcher_icon',
      largeIcon: largeIcon,
      styleInformation: styleInformation,
    );

    final notificationDetails = fln.NotificationDetails(
      android: androidDetails,
    );

    print("📲 [LOCAL NOTIF] Attempting to show with Large Icon: $title");
    try {
      await _localNotification.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
        payload: payload,
      );
      print("🎯 [LOCAL NOTIF] Notification with Large Icon SHOWN SUCCESSFULLY");
    } catch (e) {
      print("❌ [LOCAL NOTIF] Failed with Large Icon: $e");
      print("⚠️ [LOCAL NOTIF] Retrying with Standard Notification...");

      // Fallback: Standard Notification without Large Icon
      final standardDetails = fln.AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        channelDescription: 'This channel is used for important notifications',
        importance: fln.Importance.max,
        priority: fln.Priority.high,
        icon: '@mipmap/launcher_icon',
        styleInformation: fln.BigTextStyleInformation(
          body,
          contentTitle: title,
        ),
      );

      try {
        await _localNotification.show(
          id: id,
          title: title,
          body: body,
          notificationDetails: fln.NotificationDetails(
            android: standardDetails,
          ),
          payload: payload,
        );
        print(
          "🎯 [LOCAL NOTIF] Standard Notification SHOWN SUCCESSFULLY (Fallback)",
        );
      } catch (e2) {
        print(
          "❌ [LOCAL NOTIF] FATAL: Failed even with Standard Notification: $e2",
        );
      }
    }
  }

  Future<void> cancelAppointmentNotifications(String noRawat) async {
    try {
      final id = noRawat.hashCode;
      await _localNotification.cancel(id: id + 2);
      await _localNotification.cancel(id: id + 3);
      await _localNotification.cancel(id: id + 20);
      await _localNotification.cancel(id: id + 30);
      print("🚫 [LOCAL NOTIF] Cancelled notifications for appointment: $noRawat");
    } catch (e) {
      print("⚠️ [LOCAL NOTIF] Failed to cancel notifications for $noRawat: $e");
    }
  }

  Future<List<fln.PendingNotificationRequest>> getPendingNotificationRequests() async {
    return await _localNotification.pendingNotificationRequests();
  }

  Future<void> cancelNotification(int id) async {
    await _localNotification.cancel(id: id);
  }
}

// Top-level function for background handling
@pragma('vm:entry-point')
Future<void> handleBackgroundMessage(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Already initialized
  }
  print("🌙 Background Message Handler: ${message.messageId}");
  print("📦 Background Message Data: ${message.data}");

  // Handle Medication Reminder (Direct Data Message)
  if (message.data['type'] == 'MEDICINE_REMINDER_DIRECT') {
    try {
      await GetStorage.init();
      final fbApi = FirebaseApi();
      await fbApi.initLocalNotification();

      final title = message.data['title'] ?? 'Pengingat Obat';
      final body = message.data['body'] ?? 'Waktunya minum obat.';
      final imageUrl = message.data['image'];
      final payload = jsonEncode(message.data);

      await fbApi.showMedicationReminder(
        title: title,
        body: body,
        payload: payload,
        imageUrl: imageUrl,
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      );
      print("✅ [BG] Medication Reminder shown with Large Icon");
    } catch (e) {
      print("❌ [BG] Error showing medication reminder: $e");
    }
    return;
  }

  // Handle Appointment Reminder (Janji Pasien) in background
  if (message.data['type'] == 'APPOINTMENT_REMINDER') {
    try {
      await GetStorage.init();
      final fbApi = FirebaseApi();
      await fbApi.initLocalNotification();

      final title = message.data['title'] ?? 'Pengingat Jadwal';
      final body = message.data['body'] ?? 'Mengingatkan jadwal pemeriksaan.';
      final imageUrl = message.data['image'];
      final payload = jsonEncode(message.data);

      await fbApi.showMedicationReminder(
        title: title,
        body: body,
        payload: payload,
        imageUrl: imageUrl,
        id: message.hashCode,
      );
      print("✅ [BG] Appointment Reminder shown");
    } catch (e) {
      print("❌ [BG] Error showing appointment reminder: $e");
    }
    return;
  }

  if (message.data['type'] == 'SYNC_MEDICINE') {
    final noResep = message.data['no_resep'];
    if (noResep != null) {
      try {
        await GetStorage.init();
        // Initialize timezone for the background isolate
        tz.initializeTimeZones();
        tzi.setLocalLocation(tzi.getLocation('Asia/Jakarta'));

        // Initialize notification for the background isolate
        final fbApi = FirebaseApi();
        await fbApi.initLocalNotification();

        final dio = Dio(
          BaseOptions(
            baseUrl: ApiConfig.baseUrl,
            responseType: ResponseType.json,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
          ),
        );

        final token = GetStorage().read('token');
        if (token != null) {
          dio.options.headers['Authorization'] = 'Bearer $token';
        }
        dio.options.headers['Accept'] = 'application/json';
        dio.options.headers['X-App-Type'] = 'mobile';

        final entrypointUrl = 'farmasi/resep/$noResep';
        print("Background Sync Request: ${ApiConfig.baseUrl}$entrypointUrl");
        final response = await dio.get(entrypointUrl);
        if (response.data['success'] == true) {
          final prescription = response.data['data'];
          final int count = await MedicationReminderService().scheduleReminders(
            prescription,
          );

          await fbApi.showSimpleNotification(
            title: "Sinkronisasi Jadwal Obat 💊",
            body:
                "$count pengingat obat berhasil disinkronkan ke jadwal harian Anda.",
            payload: jsonEncode({"no_resep": noResep}),
          );

          print("Medication reminders scheduled for $noResep ($count slots)");
        }
      } catch (e) {
        print("Error in background sync: $e");
      }
    }
  }
}
