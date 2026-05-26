import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/app_localizations.dart';
import '../../models/session_record.dart';
import '../../services/background/background_timer.dart';
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
  NotifTier? _lastNotifTier;
  static const _persistInterval = Duration(seconds: 30);
  static const _reminderId = 100;

  SedentaryNotifier() : super(const SedentaryState()) {
    _loadAndStart();
  }

  // ── Lifecycle ──

  Future<void> _loadAndStart() async {
    final config = await StorageService.loadConfig();

    // If the foreground service was running (app previously killed),
    // restore from it; otherwise load from Hive.
    int restoredElapsed;
    bool active;
    DateTime lastActive;

    final svcRunning = await BackgroundTimer.isRunning();
    if (svcRunning) {
      restoredElapsed = await BackgroundTimer.getElapsed();
      await BackgroundTimer.stop();
      lastActive = DateTime.now();
      active = true;
    } else {
      final (elapsed, a, la) = await StorageService.loadTimerState();
      restoredElapsed = elapsed;
      active = a;
      lastActive = la;

      final now = DateTime.now();
      if (active && restoredElapsed > 0) {
        final bgDelta = now.difference(lastActive).inSeconds;
        if (bgDelta > 0 && bgDelta < 86400) {
          restoredElapsed += bgDelta;
        }
      }
    }

    _lastActiveAt = lastActive;
    _lastResetAt = lastActive;

    state = state.copyWith(
      elapsedSeconds: restoredElapsed,
      isActive: active,
      thresholdMinutes: config.sedentaryIntervalMinutes,
    );

    _startTicking();
  }

  Future<void> onPaused() async {
    _lastActiveAt = DateTime.now();
    await _persist();
    // Start foreground service so the timer keeps running.
    if (state.isActive) {
      await BackgroundTimer.start(state.elapsedSeconds);
    }
  }

  Future<void> onResumed() async {
    // Sync from foreground service — it has the authoritative elapsed time.
    if (state.isActive) {
      final svcElapsed = await BackgroundTimer.getElapsed();
      await BackgroundTimer.stop();
      if (svcElapsed > state.elapsedSeconds) {
        state = state.copyWith(elapsedSeconds: svcElapsed);
      }
    }

    _lastActiveAt = DateTime.now();
    final config = await StorageService.loadConfig();
    state = state.copyWith(
        thresholdMinutes: config.sedentaryIntervalMinutes);
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
        !state.hasCrossedThreshold && newElapsed >= thresholdSeconds;

    state = state.copyWith(
      elapsedSeconds: newElapsed,
      hasCrossedThreshold: crossed || state.hasCrossedThreshold,
    );

    // ── Notification escalation ──
    // gentle at 1.0x threshold, normal at 1.5x, urgent at 2.0x,
    // then urgent repeat every 0.5x.
    final ratio = newElapsed / thresholdSeconds;
    final locale = AppLocalizations.resolvedLocale;

    if (crossed && _lastNotifTier == null) {
      _lastNotifTier = NotifTier.gentle;
      _fireNotif(NotifTier.gentle, locale);
    } else if (ratio >= 2.0 &&
        (_lastNotifTier == NotifTier.normal ||
            _lastNotifTier == NotifTier.gentle)) {
      // Jump to urgent if we passed 2x
      if (_lastNotifTier != NotifTier.urgent) {
        _lastNotifTier = NotifTier.urgent;
        _fireNotif(NotifTier.urgent, locale);
      }
    } else if (ratio >= 1.5 && _lastNotifTier == NotifTier.gentle) {
      _lastNotifTier = NotifTier.normal;
      _fireNotif(NotifTier.normal, locale);
    }

    // Periodic urgent re-reminder every 0.5x beyond 2.0x
    if (ratio >= 2.0) {
      final excess = newElapsed - (thresholdSeconds * 2);
      if (excess > 0 && excess % (thresholdSeconds ~/ 2) == 0) {
        _fireNotif(NotifTier.urgent, locale);
      }
    }
  }

  void _fireNotif(NotifTier tier, String locale) {
    final body = tier == NotifTier.urgent
        ? AppLocalizations.notifUrgent(locale, state.elapsedMinutes)
        : AppLocalizations.notifBodyFor(locale, state.elapsedMinutes);
    NotificationService.show(
      tier: tier,
      id: _reminderId,
      title: AppLocalizations.notifTitleFor(locale, tier),
      body: body,
    );
  }

  // ── Actions ──

  Future<void> reset() async {
    final today = await StorageService.todayRecord();
    await StorageService.saveRecord(
      today.copyWith(
        totalSitsMinutes:
            today.totalSitsMinutes + state.elapsedMinutes,
        standBreaks: today.standBreaks + 1,
      ),
    );

    _lastNotifTier = null;
    _lastResetAt = DateTime.now();
    _lastActiveAt = DateTime.now();
    state = const SedentaryState();

    await BackgroundTimer.stop();
    await NotificationService.cancel(_reminderId);

    await _persist();
  }

  void pause() {
    state = state.copyWith(isActive: false, hasCrossedThreshold: false);
    _lastNotifTier = null;
    BackgroundTimer.stop();
    _persist();
  }

  void resume() {
    state = state.copyWith(isActive: true, hasCrossedThreshold: false);
    _lastNotifTier = null;
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
