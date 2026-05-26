import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/session_record.dart';
import '../../services/notification_service.dart';
import '../../services/storage_service.dart';

class SedentaryState {
  final int elapsedSeconds;
  final int thresholdMinutes;
  final bool isActive;
  final bool hasCrossedThreshold;

  const SedentaryState({
    this.elapsedSeconds = 0,
    this.thresholdMinutes = 45,
    this.isActive = true,
    this.hasCrossedThreshold = false,
  });

  int get elapsedMinutes => elapsedSeconds ~/ 60;

  double get progress =>
      (elapsedSeconds / (thresholdMinutes * 60)).clamp(0.0, 1.0);

  String get message {
    if (elapsedSeconds < 60) return 'Settle in.\nLet your shoulders drop.';
    if (progress < 0.30) return 'No need to rush.\nYou\'re doing fine.';
    if (progress < 0.55) return 'How does your body feel\nright now?';
    if (progress < 0.80) return 'Your body might enjoy\na gentle stretch soon.';
    if (progress < 1.0) {
      return 'Whenever you\'re ready,\ngo ahead and stand up.';
    }
    return 'You\'ve been still for a while.\nEven a short walk will feel nice.';
  }

  SedentaryState copyWith({
    int? elapsedSeconds,
    int? thresholdMinutes,
    bool? isActive,
    bool? hasCrossedThreshold,
  }) =>
      SedentaryState(
        elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
        thresholdMinutes: thresholdMinutes ?? this.thresholdMinutes,
        isActive: isActive ?? this.isActive,
        hasCrossedThreshold: hasCrossedThreshold ?? this.hasCrossedThreshold,
      );
}

class SedentaryNotifier extends StateNotifier<SedentaryState> {
  Timer? _timer;
  Timer? _persistTimer;
  DateTime _lastActiveAt = DateTime.now();
  DateTime _lastResetAt = DateTime.now();
  bool _thresholdNotified = false;
  static const _persistInterval = Duration(seconds: 30);
  static const _reminderId = 100;

  SedentaryNotifier() : super(const SedentaryState()) {
    _loadAndStart();
  }

  // ── Lifecycle ──

  Future<void> _loadAndStart() async {
    final (elapsed, active, lastActive) =
        await StorageService.loadTimerState();
    _lastActiveAt = lastActive;
    _lastResetAt = lastActive; // approximate; fine for v1

    // If the timer was active and we're resuming from background,
    // add the background duration.
    final now = DateTime.now();
    int restoredElapsed = elapsed;
    if (active && elapsed > 0) {
      final bgDelta = now.difference(_lastActiveAt).inSeconds;
      if (bgDelta > 0 && bgDelta < 86400) {
        // Cap at 24h — if it's been days, don't add it.
        restoredElapsed += bgDelta;
      }
    }

    state = state.copyWith(
      elapsedSeconds: restoredElapsed,
      isActive: active,
    );

    _startTicking();
  }

  /// Called when the app goes to background.
  Future<void> onPaused() async {
    _lastActiveAt = DateTime.now();
    await _persist();
  }

  /// Called when the app returns to foreground.
  Future<void> onResumed() async {
    final now = DateTime.now();
    final bgDelta = now.difference(_lastActiveAt).inSeconds;
    if (bgDelta > 0 && bgDelta < 86400 && state.isActive) {
      state = state.copyWith(
        elapsedSeconds: state.elapsedSeconds + bgDelta,
      );
    }
    _lastActiveAt = now;
    await _persist();
  }

  // ── Timer ──

  void _startTicking() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());

    _persistTimer?.cancel();
    _persistTimer = Timer.periodic(_persistInterval, (_) => _persist());
  }

  void _tick() {
    if (!state.isActive) return;

    final newElapsed = state.elapsedSeconds + 1;
    final thresholdSeconds = state.thresholdMinutes * 60;
    final crossed =
        !_thresholdNotified && newElapsed >= thresholdSeconds;

    state = state.copyWith(
      elapsedSeconds: newElapsed,
      hasCrossedThreshold: crossed || state.hasCrossedThreshold,
    );

    if (crossed) {
      _thresholdNotified = true;
      _notifyThreshold();
    }
  }

  // ── Actions ──

  /// User stood up — reset the timer and log the session.
  Future<void> reset() async {
    // Save session record.
    final today = await StorageService.todayRecord();
    await StorageService.saveRecord(
      today.copyWith(
        totalSitsMinutes:
            today.totalSitsMinutes + state.elapsedMinutes,
        standBreaks: today.standBreaks + 1,
      ),
    );

    // Reset local state.
    _thresholdNotified = false;
    _lastResetAt = DateTime.now();
    _lastActiveAt = DateTime.now();
    state = const SedentaryState();

    // Clear pending reminders.
    await NotificationService.cancel(_reminderId);

    await _persist();
  }

  void pause() {
    state = state.copyWith(isActive: false);
    _persist();
  }

  void resume() {
    state = state.copyWith(isActive: true, hasCrossedThreshold: false);
    _thresholdNotified = false;
    _lastActiveAt = DateTime.now();
    _persist();
  }

  // ── Persistence ──

  Future<void> _persist() async {
    await StorageService.saveTimerState(
      elapsedSeconds: state.elapsedSeconds,
      isActive: state.isActive,
      lastActiveAt: _lastActiveAt,
    );
  }

  // ── Notifications ──

  void _notifyThreshold() async {
    await NotificationService.showGentle(
      id: _reminderId,
      title: 'Time to move',
      body: 'You’ve been sitting for ${state.elapsedMinutes} minutes. '
          'A short walk would feel nice.',
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _persistTimer?.cancel();
    _persist();
    super.dispose();
  }
}

final sedentaryProvider =
    StateNotifierProvider<SedentaryNotifier, SedentaryState>(
  (ref) => SedentaryNotifier(),
);
