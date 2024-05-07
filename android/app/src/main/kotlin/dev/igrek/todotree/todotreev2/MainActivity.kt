package dev.igrek.todotree.v2

import android.content.Intent
import android.view.KeyEvent
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    private var keyEventMethodChannel: MethodChannel? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        keyEventMethodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "keyboard_event_channel")

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "minimize_channel").setMethodCallHandler { call, result ->
            if (call.method == "minimize") {
                minimize()
                result.success(true)
            } else {
                result.notImplemented()
            }
        }
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

    private fun minimize() {
        val startMain = Intent(Intent.ACTION_MAIN)
        startMain.addCategory(Intent.CATEGORY_HOME)
        startMain.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        startActivity(startMain)
    }
}
