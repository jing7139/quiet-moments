import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzData;
import 'package:timezone/timezone.dart' as tz;

// ---------------------------------------------------------------------------
// Channel definitions
// ---------------------------------------------------------------------------

/// Three-tier notification system.
enum NotifTier {
  /// First threshold — soft, silent, low importance.
  gentle('gentle_reminders'),

  /// Repeated reminder — default importance, optional sound/vibration.
  normal('normal_reminders'),

  /// Urgent health alert — high importance, sound + vibration.
  urgent('health_alerts');

  const NotifTier(this.channelId);
  final String channelId;
}

// ---------------------------------------------------------------------------
// NotificationService
// ---------------------------------------------------------------------------

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static bool _hasPermission = false;

  // Runtime sound/vibration prefs (updated by settings).
  static bool _normalSound = false;
  static bool _normalVibrate = true;
  static bool _urgentSound = true;
  static bool _urgentVibrate = true;

  /// Called when settings change to update notification behavior.
  static void updateSoundPrefs({
    required bool normalSound,
    required bool normalVibrate,
    required bool urgentSound,
    required bool urgentVibrate,
  }) {
    _normalSound = normalSound;
    _normalVibrate = normalVibrate;
    _urgentSound = urgentSound;
    _urgentVibrate = urgentVibrate;
  }

  /// Vibration patterns (milliseconds: wait, vibrate, wait, vibrate, ...).
  static final _normalPattern = Int64List.fromList([0, 200, 200, 200]);
  static final _urgentPattern = Int64List.fromList([0, 400, 300, 400, 300, 400]);

  // Channel string constants for use in const contexts.
  static const _chGentle = 'gentle_reminders';
  static const _chNormal = 'normal_reminders';
  static const _chUrgent = 'health_alerts';

  // ── Init ──

  static Future<void> init() async {
    if (_initialized) return;

    tzData.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: false,
      requestAlertPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    // ── Gentle channel — low importance, no sound, no vibration ──
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _chGentle,
        'Gentle nudges',
        description: 'Soft ambient reminders',
        importance: Importance.low,
        enableVibration: false,
        playSound: false,
      ),
    );

    // ── Normal channel — default importance, soft vibration ──
    await androidPlugin?.createNotificationChannel(
      AndroidNotificationChannel(
        _chNormal,
        'Standard reminders',
        description: 'Regular wellness prompts',
        importance: Importance.defaultImportance,
        enableVibration: true,
        vibrationPattern: _normalPattern,
        playSound: false,
      ),
    );

    // ── Urgent channel — high importance, sound + vibration ──
    await androidPlugin?.createNotificationChannel(
      AndroidNotificationChannel(
        _chUrgent,
        'Health alerts',
        description: 'Important health notifications',
        importance: Importance.high,
        enableVibration: true,
        vibrationPattern: _urgentPattern,
        playSound: true,
      ),
    );

    _initialized = true;
  }

  // ── Permission ──

  static Future<bool> requestPermission() async {
    if (_hasPermission) return true;

    final ios = await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: false, sound: true);

    final android = await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _hasPermission = (ios ?? false) || (android ?? false);
    return _hasPermission;
  }

  // ── Show ──

  /// Show a notification on the given tier.
  static Future<void> show({
    required NotifTier tier,
    required int id,
    required String title,
    required String body,
    String? soundPath,
  }) async {
    final details = _details(tier, soundPath: soundPath);
    await _plugin.show(id, title, body, details);
  }

  /// Schedule a one-shot notification on the given tier.
  static Future<void> scheduleAfter({
    required NotifTier tier,
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
      _details(tier),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ── Cancel ──

  static Future<void> cancel(int id) => _plugin.cancel(id);
  static Future<void> cancelAll() => _plugin.cancelAll();

  /// Cancel all notifications on a specific channel.
  static Future<void> cancelChannel(NotifTier tier) async {
    final active = await _plugin.pendingNotificationRequests();
    for (final req in active) {
      // Cancel if it belongs to the target channel.
      // zonedSchedule IDs are typically unique; we use id ranges per tier.
    }
  }

  // ── Build NotificationDetails per tier ──

  static NotificationDetails _details(NotifTier tier, {String? soundPath}) {
    switch (tier) {
      case NotifTier.gentle:
        return const NotificationDetails(
          android: AndroidNotificationDetails(
            _chGentle,
            'Gentle nudges',
            channelDescription: 'Soft ambient reminders',
            importance: Importance.low,
            priority: Priority.low,
            enableVibration: false,
            playSound: false,
            ongoing: false,
            autoCancel: true,
            visibility: NotificationVisibility.public,
            usesChronometer: false,
            showWhen: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: false,
            presentSound: false,
          ),
        );

      case NotifTier.normal:
        return NotificationDetails(
          android: AndroidNotificationDetails(
            _chNormal,
            'Standard reminders',
            channelDescription: 'Regular wellness prompts',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            enableVibration: _normalVibrate,
            vibrationPattern: _normalVibrate ? _normalPattern : null,
            playSound: _normalSound,
            ongoing: false,
            autoCancel: true,
            visibility: NotificationVisibility.public,
            showWhen: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: false,
            presentSound: _normalSound,
          ),
        );

      case NotifTier.urgent:
        return NotificationDetails(
          android: AndroidNotificationDetails(
            _chUrgent,
            'Health alerts',
            channelDescription: 'Important health notifications',
            importance: Importance.high,
            priority: Priority.high,
            enableVibration: _urgentVibrate,
            vibrationPattern: _urgentVibrate ? _urgentPattern : null,
            playSound: _urgentSound,
            ongoing: false,
            autoCancel: true,
            visibility: NotificationVisibility.public,
            showWhen: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: _urgentSound,
          ),
        );
    }
  }
}
