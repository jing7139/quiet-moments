import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/reminder_config.dart';
import '../../services/storage_service.dart';

class SettingsNotifier extends StateNotifier<ReminderConfig> {
  SettingsNotifier() : super(const ReminderConfig()) {
    _load();
  }

  Future<void> _load() async {
    state = await StorageService.loadConfig();
  }

  Future<void> setSedentaryInterval(int minutes) async {
    state = state.copyWith(sedentaryIntervalMinutes: minutes);
    await StorageService.saveConfig(state);
  }

  Future<void> setHydrationInterval(int minutes) async {
    state = state.copyWith(hydrationIntervalMinutes: minutes);
    await StorageService.saveConfig(state);
  }

  Future<void> setQuietMode(bool enabled) async {
    state = state.copyWith(quietMode: enabled);
    await StorageService.saveConfig(state);
  }

  Future<void> setQuietStart(String time) async {
    state = state.copyWith(quietStart: time);
    await StorageService.saveConfig(state);
  }

  Future<void> setQuietEnd(String time) async {
    state = state.copyWith(quietEnd: time);
    await StorageService.saveConfig(state);
  }

  Future<void> setNormalSound(bool v) async {
    state = state.copyWith(normalSound: v);
    await StorageService.saveConfig(state);
  }

  Future<void> setNormalVibrate(bool v) async {
    state = state.copyWith(normalVibrate: v);
    await StorageService.saveConfig(state);
  }

  Future<void> setUrgentSound(bool v) async {
    state = state.copyWith(urgentSound: v);
    await StorageService.saveConfig(state);
  }

  Future<void> setUrgentVibrate(bool v) async {
    state = state.copyWith(urgentVibrate: v);
    await StorageService.saveConfig(state);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, ReminderConfig>(
  (ref) => SettingsNotifier(),
);
