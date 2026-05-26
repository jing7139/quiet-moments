import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'core/localization/app_localizations.dart';
import 'models/session_record.dart';
import 'models/reminder_config.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Locale ──
  AppLocalizations.init();

  // ── Storage ──
  await Hive.initFlutter();
  Hive.registerAdapter(SessionRecordAdapter());
  Hive.registerAdapter(ReminderConfigAdapter());
  await Hive.openBox<String>('settings');
  await Hive.openBox<SessionRecord>('session_records');
  await StorageService.ensureSchema();

  // ── Notifications ──
  await NotificationService.init();
  Future.delayed(const Duration(seconds: 2), () {
    NotificationService.requestPermission();
  });

  runApp(
    const ProviderScope(
      child: WellnessApp(),
    ),
  );
}
