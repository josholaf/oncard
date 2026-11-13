package dev.josh.oncard

import android.content.Intent
import android.media.MediaPlayer
import android.os.Bundle
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.io.File

/**
 * Receives text selected in other apps (PROCESS_TEXT) or shared via the
 * system share sheet (ACTION_SEND text/plain), keeps the latest selection
 * in a static holder, and hands it to Flutter over 'oncard/share'.
 */
class MainActivity : FlutterActivity() {
    companion object {
        @JvmStatic
        var pendingSelectedText: String? = null
    }

    private var mediaPlayer: MediaPlayer? = null
    private var channel: MethodChannel? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        captureSelectedText(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        captureSelectedText(intent)
        // Tell Flutter a new selection arrived while the app was alive.
        channel?.invokeMethod("onSelectedText", pendingSelectedText)
    }

    private fun captureSelectedText(intent: Intent?) {
        if (intent == null) return
        when (intent.action) {
            Intent.ACTION_PROCESS_TEXT -> {
                val text = intent.getCharSequenceExtra(Intent.EXTRA_PROCESS_TEXT)
                    ?.toString()
                    ?.trim()
                if (!text.isNullOrEmpty()) pendingSelectedText = text
            }
            Intent.ACTION_SEND -> {
                if (intent.type?.startsWith("text/") == true) {
                    val text = intent.getCharSequenceExtra(Intent.EXTRA_TEXT)
                        ?.toString()
                        ?.trim()
                    if (!text.isNullOrEmpty()) pendingSelectedText = text
                }
            }
        }
    }

    override fun configureFlutterEngine(
        engine: io.flutter.embedding.engine.FlutterEngine
    ) {
        super.configureFlutterEngine(engine)
        channel = MethodChannel(engine.dartExecutor.binaryMessenger, "oncard/share")
        channel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "getSelectedText" -> {
                    result.success(pendingSelectedText)
                    pendingSelectedText = null
                }
                "shareFile" -> shareFile(call, result)
                "playAudio" -> playAudio(call, result)
                "stopAudio" -> stopAudio(result)
                else -> result.notImplemented()
            }
        }
    }

    private fun shareFile(
        call: io.flutter.plugin.common.MethodCall,
        result: MethodChannel.Result
    ) {
        try {
            val args = call.arguments as Map<*, *>
            val fileName = args["fileName"] as String
            val content = args["content"] as String
            val mime = args["mimeType"] as String? ?: "text/csv"
            val file = File(cacheDir, fileName)
            file.writeText(content)
            val uri = FileProvider.getUriForFile(
                this, "$packageName.fileprovider", file)
            val send = Intent(Intent.ACTION_SEND).apply {
                type = mime
                putExtra(Intent.EXTRA_STREAM, uri)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }
            startActivity(Intent.createChooser(send, null))
            result.success(null)
        } catch (e: Exception) {
            result.error("share_failed", e.message, null)
        }
    }

    private fun playAudio(
        call: io.flutter.plugin.common.MethodCall,
        result: MethodChannel.Result
    ) {
        try {
            val path = call.argument<String>("path")
            if (path == null) {
                result.error("no_path", null, null)
                return
            }
            mediaPlayer?.release()
            mediaPlayer = MediaPlayer().apply {
                setDataSource(path)
                setOnCompletionListener { it.release() }
                prepare()
                start()
            }
            result.success(null)
        } catch (e: Exception) {
            result.error("play_failed", e.message, null)
        }
    }

    private fun stopAudio(result: MethodChannel.Result) {
        mediaPlayer?.release()
        mediaPlayer = null
        result.success(null)
    }

    override fun onDestroy() {
        mediaPlayer?.release()
        mediaPlayer = null
        channel = null
        super.onDestroy()
    }
}
