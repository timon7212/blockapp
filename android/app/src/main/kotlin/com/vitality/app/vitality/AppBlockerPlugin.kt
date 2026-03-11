package com.vitality.app.vitality

import android.app.AppOpsManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.CountDownTimer
import android.os.Process
import android.provider.Settings
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class AppBlockerPlugin(private val context: Context) : MethodChannel.MethodCallHandler {

    companion object {
        private const val CHANNEL = "com.vitality.app_blocker"
        private const val PREFS_NAME = "app_blocker_prefs"
        private const val KEY_BLOCKED_APPS = "blocked_apps"
        private const val KEY_IS_BLOCKING = "is_blocking"

        fun registerWith(flutterEngine: FlutterEngine, context: Context) {
            val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            channel.setMethodCallHandler(AppBlockerPlugin(context))
        }
    }

    private val prefs: SharedPreferences =
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    private var unlockEndTimeMillis: Long = 0L
    private var unlockTimer: CountDownTimer? = null

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isSupported" -> result.success(true)
            "requestPermission" -> requestPermission(result)
            "hasPermission" -> result.success(hasUsageStatsPermission())
            "setBlockedApps" -> setBlockedApps(call, result)
            "startBlocking" -> startBlocking(result)
            "stopBlocking" -> stopBlocking(result)
            "unlockTemporarily" -> unlockTemporarily(call, result)
            "isBlocking" -> result.success(isCurrentlyBlocking())
            "getRemainingUnlockTime" -> result.success(getRemainingUnlockSeconds())
            else -> result.notImplemented()
        }
    }

    private fun hasUsageStatsPermission(): Boolean {
        val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOps.unsafeCheckOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            Process.myUid(),
            context.packageName
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun requestPermission(result: MethodChannel.Result) {
        try {
            val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            context.startActivity(intent)
            result.success(true)
        } catch (e: Exception) {
            result.success(false)
        }
    }

    private fun setBlockedApps(call: MethodCall, result: MethodChannel.Result) {
        val appIds = call.argument<List<String>>("appIds") ?: emptyList()
        prefs.edit().putStringSet(KEY_BLOCKED_APPS, appIds.toSet()).apply()
        result.success(null)
    }

    private fun startBlocking(result: MethodChannel.Result) {
        prefs.edit().putBoolean(KEY_IS_BLOCKING, true).apply()
        // TODO: Start a foreground service that monitors foreground app via
        //       UsageStatsManager and shows an overlay when a blocked app is detected.
        result.success(null)
    }

    private fun stopBlocking(result: MethodChannel.Result) {
        prefs.edit().putBoolean(KEY_IS_BLOCKING, false).apply()
        cancelUnlockTimer()
        // TODO: Stop the foreground monitoring service.
        result.success(null)
    }

    private fun unlockTemporarily(call: MethodCall, result: MethodChannel.Result) {
        val minutes = call.argument<Int>("minutes") ?: 0
        if (minutes <= 0) {
            result.success(null)
            return
        }

        val durationMillis = minutes * 60_000L
        unlockEndTimeMillis = System.currentTimeMillis() + durationMillis

        cancelUnlockTimer()
        unlockTimer = object : CountDownTimer(durationMillis, 1000) {
            override fun onTick(millisUntilFinished: Long) {}
            override fun onFinish() {
                unlockEndTimeMillis = 0L
                // Re-engage blocking when timer expires.
            }
        }.start()

        result.success(null)
    }

    private fun cancelUnlockTimer() {
        unlockTimer?.cancel()
        unlockTimer = null
        unlockEndTimeMillis = 0L
    }

    private fun isCurrentlyBlocking(): Boolean {
        val flagOn = prefs.getBoolean(KEY_IS_BLOCKING, false)
        if (!flagOn) return false
        if (unlockEndTimeMillis > System.currentTimeMillis()) return false
        return true
    }

    private fun getRemainingUnlockSeconds(): Int {
        val remaining = unlockEndTimeMillis - System.currentTimeMillis()
        return if (remaining > 0) (remaining / 1000).toInt() else 0
    }
}
