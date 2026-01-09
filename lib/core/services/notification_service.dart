import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        print("🔔 Notification clicked: ${response.payload}");
      },
    );
  }

  Future<void> requestPermissions() async {
    // iOS permissions
    final iosPlugin = notificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);

    // Android 13+ (API 33+) notification permission
    // For Android 12 and below, this will return granted automatically
    final status = await Permission.notification.request();

    if (status.isDenied) {
      print("⚠️ Notification permission denied");
    } else if (status.isPermanentlyDenied) {
      print(
        "⚠️ Notification permission permanently denied. Please enable in settings.",
      );
    }
  }

  /// ------------------------------------------------
  /// 🔥 Task Scheduler — Works on flutter_local_notifications 19.x
  /// ------------------------------------------------
  Future<void> scheduleTaskNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String payload,
  }) async {
    final tz.TZDateTime tzTime = tz.TZDateTime.from(scheduledTime, tz.local);
    final now = tz.TZDateTime.now(tz.local);

    // ✅ Check if the scheduled time is in the future
    if (tzTime.isBefore(now)) {
      print(
        "⚠️ Skipping notification (ID: $id) - scheduled time is in the past",
      );
      return; // Don't schedule notifications for past times
    }

    const androidDetails = AndroidNotificationDetails(
      'task_channel',
      'Task Reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzTime,
      notificationDetails,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    print("✅ Notification scheduled (ID: $id) for ${tzTime.toString()}");
  }

  Future<void> cancelNotification(int id) async {
    await notificationsPlugin.cancel(id);
  }
}
