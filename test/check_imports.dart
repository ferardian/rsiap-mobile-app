import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  tz.initializeTimeZones();
  print(UILocalNotificationDateInterpretation.absoluteTime);
  print(AndroidScheduleMode.exactAllowWhileIdle);
}
