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
  final String quietStart; // "22:00"

  @HiveField(4)
  final String quietEnd; // "08:00"

  const ReminderConfig({
    this.sedentaryIntervalMinutes = 45,
    this.hydrationIntervalMinutes = 60,
    this.quietMode = true,
    this.quietStart = '22:00',
    this.quietEnd = '08:00',
  });

  ReminderConfig copyWith({
    int? sedentaryIntervalMinutes,
    int? hydrationIntervalMinutes,
    bool? quietMode,
    String? quietStart,
    String? quietEnd,
  }) =>
      ReminderConfig(
        sedentaryIntervalMinutes:
            sedentaryIntervalMinutes ?? this.sedentaryIntervalMinutes,
        hydrationIntervalMinutes:
            hydrationIntervalMinutes ?? this.hydrationIntervalMinutes,
        quietMode: quietMode ?? this.quietMode,
        quietStart: quietStart ?? this.quietStart,
        quietEnd: quietEnd ?? this.quietEnd,
      );
}
