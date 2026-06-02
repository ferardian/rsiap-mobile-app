import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as fln;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final fln.FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      fln.FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz_data.initializeTimeZones();
    // Set default location to Jakarta/Indonesia if needed, or rely on local
    // tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const fln.AndroidInitializationSettings initializationSettingsAndroid =
        fln.AndroidInitializationSettings('@mipmap/ic_launcher');

    final fln.DarwinInitializationSettings initializationSettingsDarwin =
        fln.DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    final fln.InitializationSettings initializationSettings =
        fln.InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (fln.NotificationResponse details) {
        // Handle notification tap
      },
    );
  }

  Future<void> requestPermissions() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          fln.IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          fln.AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: fln.NotificationDetails(
        android: fln.AndroidNotificationDetails(
          'vaccination_channel',
          'Vaccination Reminders',
          channelDescription: 'Reminders for child vaccination schedules',
          importance: fln.Importance.max,
          priority: fln.Priority.high,
          largeIcon: const fln.DrawableResourceAndroidBitmap('app_logo'),
          styleInformation: fln.BigTextStyleInformation(
            body,
            htmlFormatBigText: true,
            contentTitle: title,
            htmlFormatContentTitle: true,
          ),
        ),
        iOS: fln.DarwinNotificationDetails(),
      ),
      androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> scheduleVaccinationReminders(
    List<dynamic> vaccines,
    String childName,
  ) async {
    final now = DateTime.now();

    for (var v in vaccines) {
      // Check if status implies upcoming
      if (v['status'] == 'due_soon' ||
          v['status'] == 'future' ||
          v['status'] == 'overdue') {
        if (v['due_date'] == null) continue;

        try {
          DateTime dueDate = DateTime.parse(v['due_date']);
          int id = v['id'] is String ? int.tryParse(v['id']) ?? 0 : v['id'];
          if (id == 0) continue;

          // Schedule H-7 (1 Week Before) at 09:00
          DateTime remindMinus7 = dueDate.subtract(const Duration(days: 7));
          remindMinus7 = DateTime(
            remindMinus7.year,
            remindMinus7.month,
            remindMinus7.day,
            9,
            0,
            0,
          );

          if (remindMinus7.isAfter(now)) {
            await scheduleNotification(
              id: id + 20000,
              title: 'Pengingat Imunisasi Minggu Depan',
              body:
                  'Minggu depan jadwal imunisasi ${v['nama_vaksin']} untuk $childName. Siapkan waktu ya!',
              scheduledDate: remindMinus7,
            );
          }

          // Schedule 1 day before at 09:00
          DateTime remindMinus1 = dueDate.subtract(const Duration(days: 1));
          remindMinus1 = DateTime(
            remindMinus1.year,
            remindMinus1.month,
            remindMinus1.day,
            9,
            0,
            0,
          );

          if (remindMinus1.isAfter(now)) {
            await scheduleNotification(
              id: id,
              title: 'Pengingat Imunisasi Besok',
              body:
                  'Besok jadwal imunisasi ${v['nama_vaksin']} untuk $childName.',
              scheduledDate: remindMinus1,
            );
          }

          // Schedule D-Day at 07:00
          DateTime remindDay = DateTime(
            dueDate.year,
            dueDate.month,
            dueDate.day,
            7,
            0,
            0,
          );

          if (remindDay.isAfter(now)) {
            await scheduleNotification(
              id: id + 10000,
              title: 'Jadwal Imunisasi Hari Ini',
              body:
                  'Hari ini jadwal imunisasi ${v['nama_vaksin']} untuk $childName. Jangan lupa ya!',
              scheduledDate: remindDay,
            );
          }
        } catch (e) {
          print("Error scheduling notification for ${v['nama_vaksin']}: $e");
        }
      }
    }
  }

  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
