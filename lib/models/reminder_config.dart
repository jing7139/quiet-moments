import 'package:hive/hive.dart';

part 'reminder_config.g.dart';

@HiveType(typeId: 1)
class ReminderConfig {
  @HiveField(0)
  final int sedentaryIntervalMinutes;

  @HiveField(1)
  final int hydrationIntervalMinutes;

  @HiveField(2)
  final bool quietMode;

  @HiveField(3)
  final String quietStart;

  @HiveField(4)
  final String quietEnd;

  // ── Notification preferences ──

  @HiveField(5)
  final bool normalSound;

  @HiveField(6)
  final bool normalVibrate;

  @HiveField(7)
  final bool urgentSound;

  @HiveField(8)
  final bool urgentVibrate;

  const ReminderConfig({
    this.sedentaryIntervalMinutes = 45,
    this.hydrationIntervalMinutes = 60,
    this.quietMode = true,
    this.quietStart = '22:00',
    this.quietEnd = '08:00',
    this.normalSound = false,
    this.normalVibrate = true,
    this.urgentSound = true,
    this.urgentVibrate = true,
  });

  ReminderConfig copyWith({
    int? sedentaryIntervalMinutes,
    int? hydrationIntervalMinutes,
    bool? quietMode,
    String? quietStart,
    String? quietEnd,
    bool? normalSound,
    bool? normalVibrate,
    bool? urgentSound,
    bool? urgentVibrate,
  }) =>
      ReminderConfig(
        sedentaryIntervalMinutes:
            sedentaryIntervalMinutes ?? this.sedentaryIntervalMinutes,
        hydrationIntervalMinutes:
            hydrationIntervalMinutes ?? this.hydrationIntervalMinutes,
        quietMode: quietMode ?? this.quietMode,
        quietStart: quietStart ?? this.quietStart,
        quietEnd: quietEnd ?? this.quietEnd,
        normalSound: normalSound ?? this.normalSound,
        normalVibrate: normalVibrate ?? this.normalVibrate,
        urgentSound: urgentSound ?? this.urgentSound,
        urgentVibrate: urgentVibrate ?? this.urgentVibrate,
      );
}
