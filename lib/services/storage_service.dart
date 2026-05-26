import 'package:hive_flutter/hive_flutter.dart';
import '../models/session_record.dart';
import '../models/reminder_config.dart';

class StorageService {
  StorageService._();

  static const _recordsBox = 'session_records';
  static const _settingsBox = 'settings';
  static const _configKey = 'reminder_config';
  static const _timerStateKey = 'timer_state';
  static const _hydrationPrefix = 'hydration_';

  /// Increment when data format changes to trigger migration.
  static const _currentSchemaVersion = 1;
  static const _versionKey = '_schema_version';

  // ── Box access ──

  static Future<Box<String>> get _settings async =>
      Hive.openBox<String>(_settingsBox);

  static Future<Box<SessionRecord>> get _records async =>
      Hive.openBox<SessionRecord>(_recordsBox);

  // ── Schema migration ──

  /// Called once at startup. Runs any pending data migrations.
  static Future<void> ensureSchema() async {
    final box = await _settings;
    final stored = int.tryParse(box.get(_versionKey, defaultValue: '0') ?? '0') ?? 0;

    if (stored < _currentSchemaVersion) {
      await _migrate(stored, _currentSchemaVersion);
      await box.put(_versionKey, _currentSchemaVersion.toString());
    }
  }

  static Future<void> _migrate(int from, int to) async {
    // Future migrations go here.
    // e.g., if (from < 2) { ... } — convert old format to new.
  }

  // ── Timer state ──

  /// Persist timer state so it survives restarts and backgrounding.
  static Future<void> saveTimerState({
    required int elapsedSeconds,
    required bool isActive,
    required DateTime lastActiveAt,
  }) async {
    final box = await _settings;
    final value =
        '$elapsedSeconds|$isActive|${lastActiveAt.toIso8601String()}';
    await box.put(_timerStateKey, value);
  }

  /// Returns (elapsedSeconds, isActive, lastActiveAt).
  /// Defaults to (0, true, now) if nothing persisted or data corrupted.
  static Future<(int, bool, DateTime)> loadTimerState() async {
    try {
      final box = await _settings;
      final raw = box.get(_timerStateKey);
      if (raw == null) return (0, true, DateTime.now());

      final parts = raw.split('|');
      final elapsed = int.tryParse(parts[0]) ?? 0;
      final active = parts.length > 1 ? parts[1] == 'true' : true;
      final lastActive = parts.length > 2
          ? DateTime.tryParse(parts[2]) ?? DateTime.now()
          : DateTime.now();

      return (elapsed, active, lastActive);
    } catch (_) {
      return (0, true, DateTime.now());
    }
  }

  // ── Session records ──

  static String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static Future<void> saveRecord(SessionRecord record) async {
    final box = await _records;
    await box.put(_dateKey(record.date), record);
  }

  static Future<SessionRecord?> recordFor(DateTime date) async {
    final box = await _records;
    return box.get(_dateKey(date));
  }

  /// Get records for the last [days] days (including today).
  /// Returns a list ordered oldest → newest, with missing days as defaults.
  static Future<List<SessionRecord>> recentRecords(int days) async {
    final box = await _records;
    final now = DateTime.now();
    final result = <SessionRecord>[];
    for (int i = days - 1; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      final key = _dateKey(date);
      final record = box.get(key) ?? SessionRecord(date: date);
      result.add(record);
    }
    return result;
  }

  static Future<SessionRecord> todayRecord() async {
    final existing = await recordFor(DateTime.now());
    return existing ?? SessionRecord(date: DateTime.now());
  }

  // ── Hydration ──

  static Future<int> hydrationCount(DateTime date) async {
    final box = await _settings;
    final raw = box.get('$_hydrationPrefix${_dateKey(date)}');
    return int.tryParse(raw ?? '') ?? 0;
  }

  static Future<void> setHydrationCount(DateTime date, int count) async {
    final box = await _settings;
    await box.put('$_hydrationPrefix${_dateKey(date)}', count.toString());
  }

  // ── Config ──

  static Future<ReminderConfig> loadConfig() async {
    try {
      final box = await _settings;
      final json = box.get(_configKey);
      if (json == null) return const ReminderConfig();
      final parts = json.split('|');
      return ReminderConfig(
        sedentaryIntervalMinutes: int.tryParse(parts[0]) ?? 45,
        hydrationIntervalMinutes: int.tryParse(parts[1]) ?? 60,
        quietMode: parts.length > 2 ? parts[2] == 'true' : true,
        quietStart: parts.length > 3 ? parts[3] : '22:00',
        quietEnd: parts.length > 4 ? parts[4] : '08:00',
        normalSound: parts.length > 5 ? parts[5] == 'true' : false,
        normalVibrate: parts.length > 6 ? parts[6] == 'true' : true,
        urgentSound: parts.length > 7 ? parts[7] == 'true' : true,
        urgentVibrate: parts.length > 8 ? parts[8] == 'true' : true,
      );
    } catch (_) {
      return const ReminderConfig();
    }
  }

  static Future<void> saveConfig(ReminderConfig config) async {
    final box = await _settings;
    final json = [
      config.sedentaryIntervalMinutes,
      config.hydrationIntervalMinutes,
      config.quietMode,
      config.quietStart,
      config.quietEnd,
      config.normalSound,
      config.normalVibrate,
      config.urgentSound,
      config.urgentVibrate,
    ].join('|');
    await box.put(_configKey, json);
  }
}
