package com.intellex.hometek.smart_home

import android.content.Context
import com.google.android.gms.common.GoogleApiAvailability
import com.google.android.gms.common.api.GoogleApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.intellex.hometek.smart_home/isGmsAvailable"

    var concurrentContext = this@MainActivity.context
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger,CHANNEL).setMethodCallHandler() {
            call, result ->
            if (call.method == "isGmsAvailable") {
                result.success(isGmsAvailable())
            } else {
                result.notImplemented()
            }
        }
    }

    private fun isGmsAvailable(): Boolean {
        var isAvailable = false;
        if (concurrentContext != null) {
            isAvailable =
                    (GoogleApiAvailability.getInstance()
                            .isGooglePlayServicesAvailable(concurrentContext) ==
                                com.google.android.gms.common.ConnectionResult.SUCCESS)
        }
        return isAvailable
    }
}
