package dev.igrek.todotree.v2

import android.view.KeyEvent
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    private val CHANNEL = "keyboard_event_channel"
    private var keyEventMethodChannel: MethodChannel? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        keyEventMethodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
    }

    override fun onKeyDown(keyCode: Int, event: KeyEvent): Boolean {
        return when (keyCode) {
            KeyEvent.KEYCODE_VOLUME_UP -> {
                sendKeyEvent("volume_up")
                true
            }
            KeyEvent.KEYCODE_VOLUME_DOWN -> {
                sendKeyEvent("volume_down")
                true
            }
            else -> super.onKeyDown(keyCode, event)
        }
    }

    private fun sendKeyEvent(key: String) {
        keyEventMethodChannel?.invokeMethod("sendKeyEvent", mapOf("key" to key))
    }
}
