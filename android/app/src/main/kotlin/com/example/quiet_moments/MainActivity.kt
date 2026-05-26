package com.example.quiet_moments

import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val channelName = "quiet_moments/background_timer"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "startTimer" -> {
                    val elapsed = call.argument<Int>("elapsed") ?: 0
                    startTimerService(elapsed)
                    result.success(true)
                }
                "stopTimer" -> {
                    stopTimerService()
                    result.success(true)
                }
                "getElapsed" -> {
                    result.success(getTimerElapsed())
                }
                "isRunning" -> {
                    result.success(isTimerRunning())
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun startTimerService(elapsed: Int) {
        val intent = Intent(this, TimerForegroundService::class.java).apply {
            action = TimerForegroundService.ACTION_START
            putExtra(TimerForegroundService.EXTRA_ELAPSED, elapsed)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    }

    private fun stopTimerService() {
        val intent = Intent(this, TimerForegroundService::class.java).apply {
            action = TimerForegroundService.ACTION_STOP
        }
        stopService(intent)
    }

    private fun getTimerElapsed(): Int {
        // Read directly from SharedPreferences for reliability.
        val prefs = getSharedPreferences("timer_service", MODE_PRIVATE)
        return prefs.getInt("elapsed_seconds", 0)
    }

    private fun isTimerRunning(): Boolean {
        val prefs = getSharedPreferences("timer_service", MODE_PRIVATE)
        return prefs.getBoolean("is_running", false)
    }
}
