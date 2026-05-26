import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/session_record.dart';
import '../../services/storage_service.dart';

class HydrationState {
  final int glassesToday;
  final int dailyGoal;

  const HydrationState({this.glassesToday = 0, this.dailyGoal = 8});

  double get progress =>
      (glassesToday / dailyGoal).clamp(0.0, 1.0);

  HydrationState copyWith({int? glassesToday, int? dailyGoal}) =>
      HydrationState(
        glassesToday: glassesToday ?? this.glassesToday,
        dailyGoal: dailyGoal ?? this.dailyGoal,
      );
}

class HydrationNotifier extends StateNotifier<HydrationState> {
  HydrationNotifier() : super(const HydrationState()) {
    _load();
  }

  Future<void> _load() async {
    final count = await StorageService.hydrationCount(DateTime.now());
    state = state.copyWith(glassesToday: count);
  }

  Future<void> addGlass() async {
    final next = state.glassesToday + 1;
    state = state.copyWith(glassesToday: next);
    await StorageService.setHydrationCount(DateTime.now(), next);

    // Sync to today's session record for stats.
    final today = await StorageService.todayRecord();
    await StorageService.saveRecord(
      today.copyWith(hydrationCount: today.hydrationCount + 1),
    );
  }

  Future<void> removeGlass() async {
    if (state.glassesToday == 0) return;
    final next = state.glassesToday - 1;
    state = state.copyWith(glassesToday: next);
    await StorageService.setHydrationCount(DateTime.now(), next);

    final today = await StorageService.todayRecord();
    if (today.hydrationCount > 0) {
      await StorageService.saveRecord(
        today.copyWith(hydrationCount: today.hydrationCount - 1),
      );
    }
  }
}

final hydrationProvider =
    StateNotifierProvider<HydrationNotifier, HydrationState>(
  (ref) => HydrationNotifier(),
);
