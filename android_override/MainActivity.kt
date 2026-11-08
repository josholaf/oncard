package dev.josh.oncard

import android.content.Intent
import android.media.MediaPlayer
import android.os.Bundle
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.io.File

/**
 * Receives text selected in other apps (Android PROCESS_TEXT intent),
 * keeps the latest selection in a static holder, and hands it to the
 * Flutter side over the 'oncard/share' method channel. Also shares
 * files (CSV exports) through the Android share sheet and plays card
 * audio attachments with a MediaPlayer.
 */
class MainActivity : FlutterActivity() {
    companion object {
        @JvmStatic
        var pendingSelectedText: String? = null
    }

    private var mediaPlayer: MediaPlayer? = null

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
        super.onDestroy()
    }
}
