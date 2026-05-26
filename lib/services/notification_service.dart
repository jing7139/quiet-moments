import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzData;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static bool _hasPermission = false;

  static Future<void> init() async {
    if (_initialized) return;

    tzData.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    // Create the gentle Android channel upfront.
    const androidChannel = AndroidNotificationChannel(
      'gentle_reminders',
      'Gentle Reminders',
      description: 'Soft wellness nudges',
      importance: Importance.low,
      enableVibration: false,
      playSound: false,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    _initialized = true;
  }

  /// Request notification permissions. Safe to call multiple times.
  static Future<bool> requestPermission() async {
    if (_hasPermission) return true;

    final ios = await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: false, sound: false);

    final android = await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _hasPermission = (ios ?? false) || (android ?? false);
    return _hasPermission;
  }

  /// Show a silent, low-priority nudge.
  static Future<void> showGentle({
    required int id,
    required String title,
    required String body,
  }) async {
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'gentle_reminders',
          'Gentle Reminders',
          channelDescription: 'Soft wellness nudges',
          importance: Importance.low,
          priority: Priority.low,
          enableVibration: false,
          playSound: false,
          ongoing: false,
          autoCancel: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: false,
        ),
      ),
    );
  }

  /// Schedule a one-shot gentle reminder after [duration].
  static Future<void> scheduleAfter({
    required int id,
    required String title,
    required String body,
    required Duration duration,
  }) async {
    final scheduledDate = tz.TZDateTime.from(
      DateTime.now().add(duration),
      tz.local,
    );
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'gentle_reminders',
          'Gentle Reminders',
          channelDescription: 'Soft wellness nudges',
          importance: Importance.low,
          priority: Priority.low,
          enableVibration: false,
          playSound: false,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: false,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancel a specific notification by id.
  static Future<void> cancel(int id) => _plugin.cancel(id);

  /// Cancel all pending notifications.
  static Future<void> cancelAll() => _plugin.cancelAll();
}
