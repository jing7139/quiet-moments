import 'package:flutter/services.dart';

/// Manages the native Android Foreground Service via MethodChannel.
///
/// When the app goes to background, the foreground service keeps the timer
/// running. A persistent notification shows elapsed seated time.
class BackgroundTimer {
  static const _channel = MethodChannel('quiet_moments/background_timer');

  /// Start the foreground service with the current elapsed seconds.
  static Future<void> start(int elapsedSeconds) async {
    try {
      await _channel.invokeMethod('startTimer', {'elapsed': elapsedSeconds});
    } catch (_) {
      // Non-Android platforms silently ignore.
    }
  }

  /// Stop the foreground service (user stood up).
  static Future<void> stop() async {
    try {
      await _channel.invokeMethod('stopTimer');
    } catch (_) {}
  }

  /// Get elapsed seconds from the native service.
  /// Returns 0 if the service is not running or not on Android.
  static Future<int> getElapsed() async {
    try {
      final result = await _channel.invokeMethod<int>('getElapsed');
      return result ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Whether the foreground timer service is currently active.
  static Future<bool> isRunning() async {
    try {
      final result = await _channel.invokeMethod<bool>('isRunning');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }
}
