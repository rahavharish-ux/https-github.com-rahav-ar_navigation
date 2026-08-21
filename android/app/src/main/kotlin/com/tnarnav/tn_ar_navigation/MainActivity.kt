package com.tnarnav.tn_ar_navigation

import android.os.Handler
import android.os.Looper
import com.google.ar.core.ArCoreApk
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Bridges to Google's real ARCore SDK for one purpose (Phase 10): reporting
 * whether this device can actually run AR. Deliberately not routed through
 * a third-party Flutter ARCore plugin -- the community plugin ecosystem was
 * found unmaintained/unproven when this phase was built (see
 * PROJECT_STATUS.md) -- so this talks to Google's own SDK directly instead.
 */
class MainActivity : FlutterActivity() {
    private val arChannelName = "tn_ar_navigation/ar_platform"

    /**
     * ArCoreApk.checkAvailabilityAsync's callback can report a transient
     * "still checking" result (e.g. while it looks up this device model
     * over the network); Google's own docs call for re-polling on a short
     * delay until a real, final answer arrives. Capped so a persistently
     * transient result can't poll forever.
     */
    private val maxTransientPolls = 10
    private val transientPollDelayMs = 200L

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, arChannelName)
            .setMethodCallHandler { call, result ->
                if (call.method == "checkArCoreAvailability") {
                    checkAvailability(result, attempt = 0)
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun checkAvailability(result: MethodChannel.Result, attempt: Int) {
        ArCoreApk.getInstance().checkAvailabilityAsync(this) { availability ->
            if (availability.isTransient && attempt < maxTransientPolls) {
                Handler(Looper.getMainLooper()).postDelayed(
                    { checkAvailability(result, attempt + 1) },
                    transientPollDelayMs,
                )
            } else {
                result.success(availability.name)
            }
        }
    }
}
