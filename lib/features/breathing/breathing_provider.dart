import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/session_record.dart';
import '../../services/storage_service.dart';

class BreathingState {
  final bool isRunning;
  final int cyclesCompleted;
  final int sessionSeconds;

  const BreathingState({
    this.isRunning = false,
    this.cyclesCompleted = 0,
    this.sessionSeconds = 0,
  });

  BreathingState copyWith({
    bool? isRunning,
    int? cyclesCompleted,
    int? sessionSeconds,
  }) =>
      BreathingState(
        isRunning: isRunning ?? this.isRunning,
        cyclesCompleted: cyclesCompleted ?? this.cyclesCompleted,
        sessionSeconds: sessionSeconds ?? this.sessionSeconds,
      );
}

class BreathingNotifier extends StateNotifier<BreathingState> {
  Timer? _sessionTimer;

  BreathingNotifier() : super(const BreathingState());

  void start() {
    state = state.copyWith(isRunning: true);
    _sessionTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => state = state.copyWith(sessionSeconds: state.sessionSeconds + 1),
    );
  }

  void stop() {
    _sessionTimer?.cancel();
    _sessionTimer = null;
    state = state.copyWith(isRunning: false);
    _persistSession();
  }

  void onCycleComplete() {
    state = state.copyWith(cyclesCompleted: state.cyclesCompleted + 1);
  }

  Future<void> _persistSession() async {
    if (state.sessionSeconds < 10) return; // skip trivial sessions
    final today = await StorageService.todayRecord();
    await StorageService.saveRecord(
      today.copyWith(
        breathingMinutes: today.breathingMinutes + state.sessionSeconds ~/ 60,
      ),
    );
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }
}

final breathingProvider =
    StateNotifierProvider<BreathingNotifier, BreathingState>(
  (ref) => BreathingNotifier(),
);
