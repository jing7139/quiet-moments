package com.example.quiet_moments

import android.app.*
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import androidx.core.app.NotificationCompat
import java.util.*

class TimerForegroundService : Service() {

    private var timer: Timer? = null
    private var elapsedSeconds = 0
    private var isRunning = false
    private lateinit var prefs: SharedPreferences
    private lateinit var wakeLock: PowerManager.WakeLock

    companion object {
        const val CHANNEL_ID = "gentle_reminders"
        const val NOTIF_ID = 200
        const val PREFS_NAME = "timer_service"
        const val KEY_ELAPSED = "elapsed_seconds"
        const val KEY_RUNNING = "is_running"
        const val KEY_LAST_ACTIVE = "last_active_at"

        const val ACTION_START = "com.example.quiet_moments.START_TIMER"
        const val ACTION_STOP = "com.example.quiet_moments.STOP_TIMER"
        const val EXTRA_ELAPSED = "initial_elapsed"
    }

    override fun onCreate() {
        super.onCreate()
        prefs = applicationContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

        // Partial wake lock to keep CPU alive for timing accuracy.
        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
        wakeLock = pm.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK,
            "quiet_moments:timer_wakelock"
        )
        wakeLock.setReferenceCounted(false)

        createChannel()
        restoreState()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> {
                val initial = intent.getIntExtra(EXTRA_ELAPSED, 0)
                startTimer(initial)
            }
            ACTION_STOP -> {
                stopTimer()
            }
        }
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        stopTimer()
        if (wakeLock.isHeld) wakeLock.release()
        super.onDestroy()
    }

    // ── Timer ──

    private fun startTimer(initial: Int) {
        if (isRunning) return
        elapsedSeconds = initial
        isRunning = true
        if (!wakeLock.isHeld) wakeLock.acquire(10 * 60 * 1000L) // 10 min timeout

        startForeground(NOTIF_ID, buildNotification())
        timer = Timer()
        // Tick every second. Update notification every 60 ticks to reduce overhead.
        timer?.scheduleAtFixedRate(object : TimerTask() {
            private var tickCount = 0
            override fun run() {
                elapsedSeconds++
                tickCount++
                if (tickCount % 30 == 0) persistState()
                if (tickCount % 60 == 0) {
                    updateNotification()
                }
            }
        }, 1000L, 1000L)
    }

    private fun stopTimer() {
        isRunning = false
        timer?.cancel()
        timer = null
        persistState()
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    // ── State ──

    private fun restoreState() {
        elapsedSeconds = prefs.getInt(KEY_ELAPSED, 0)
    }

    private fun persistState() {
        prefs.edit()
            .putInt(KEY_ELAPSED, elapsedSeconds)
            .putBoolean(KEY_RUNNING, isRunning)
            .putString(KEY_LAST_ACTIVE, Date().toInstant().toString())
            .apply()
    }

    // ── Notification ──

    private fun createChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Gentle nudges",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Running timer notification"
                enableVibration(false)
                setSound(null, null)
                setShowBadge(false)
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    private fun buildNotification(): Notification {
        val minutes = elapsedSeconds / 60
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle("片刻")
            .setContentText("已坐 $minutes 分钟")
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setForegroundServiceBehavior(NotificationCompat.FOREGROUND_SERVICE_IMMEDIATE)
            .build()
    }

    private fun updateNotification() {
        val manager = getSystemService(NotificationManager::class.java)
        manager.notify(NOTIF_ID, buildNotification())
    }

    // ── Static helpers for Flutter MethodChannel ──

    fun getElapsedSeconds(): Int = elapsedSeconds

    fun isServiceRunning(): Boolean = isRunning
}
