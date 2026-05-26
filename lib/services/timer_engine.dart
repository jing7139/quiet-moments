import 'dart:async';

/// Simple timer engine — ticks every second.
///
/// Each feature provider listens to this stream and decides
/// whether to increment counters or fire reminders.
class TimerEngine {
  Timer? _timer;
  final _tickController = StreamController<void>.broadcast();

  Stream<void> get tick => _tickController.stream;

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _tickController.add(null);
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    stop();
    _tickController.close();
  }
}
