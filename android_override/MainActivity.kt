package com.example.oncard

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

/**
 * Receives text selected in other apps (Android PROCESS_TEXT intent),
 * keeps the latest selection in a static holder, and hands it to the
 * Flutter side over the 'oncard/share' method channel.
 */
class MainActivity : FlutterActivity() {
    companion object {
        @JvmStatic
        var pendingSelectedText: String? = null
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        captureSelectedText(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        captureSelectedText(intent)
    }

    private fun captureSelectedText(intent: Intent?) {
        if (intent?.action == Intent.ACTION_PROCESS_TEXT) {
            val text = intent.getStringExtra(Intent.EXTRA_PROCESS_TEXT)
            if (!text.isNullOrEmpty()) pendingSelectedText = text
        }
    }

    override fun configureFlutterEngine(
        engine: io.flutter.embedding.engine.FlutterEngine
    ) {
        super.configureFlutterEngine(engine)
        MethodChannel(engine.dartExecutor.binaryMessenger, "oncard/share")
            .setMethodCallHandler { call, result ->
                if (call.method == "getSelectedText") {
                    result.success(pendingSelectedText)
                    pendingSelectedText = null
                } else {
                    result.notImplemented()
                }
            }
    }
}
