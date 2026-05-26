import 'package:hive/hive.dart';

part 'session_record.g.dart';

@HiveType(typeId: 0)
class SessionRecord {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final int totalSitsMinutes;

  @HiveField(2)
  final int standBreaks;

  @HiveField(3)
  final int hydrationCount;

  @HiveField(4)
  final int stretchMinutes;

  @HiveField(5)
  final int breathingMinutes;

  const SessionRecord({
    required this.date,
    this.totalSitsMinutes = 0,
    this.standBreaks = 0,
    this.hydrationCount = 0,
    this.stretchMinutes = 0,
    this.breathingMinutes = 0,
  });

  SessionRecord copyWith({
    int? totalSitsMinutes,
    int? standBreaks,
    int? hydrationCount,
    int? stretchMinutes,
    int? breathingMinutes,
  }) =>
      SessionRecord(
        date: date,
        totalSitsMinutes: totalSitsMinutes ?? this.totalSitsMinutes,
        standBreaks: standBreaks ?? this.standBreaks,
        hydrationCount: hydrationCount ?? this.hydrationCount,
        stretchMinutes: stretchMinutes ?? this.stretchMinutes,
        breathingMinutes: breathingMinutes ?? this.breathingMinutes,
      );
}
