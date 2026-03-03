package com.enterprise.cash.cash

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "com.enterprise.cash/upi"
    private val REQUEST_CODE_UPI = 1001
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "launchUpiPayment") {
                val uri = call.argument<String>("uri")
                if (uri != null) {
                    launchUpiPayment(uri, result)
                } else {
                    result.error("INVALID_URI", "URI is null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun launchUpiPayment(uriString: String, result: MethodChannel.Result) {
        pendingResult = result
        try {
            val uri = Uri.parse(uriString)
            val intent = Intent(Intent.ACTION_VIEW, uri)
            startActivityForResult(intent, REQUEST_CODE_UPI)
        } catch (e: Exception) {
            pendingResult = null
            result.error("LAUNCH_FAILED", "Could not launch UPI intent: ${e.message}", null)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == REQUEST_CODE_UPI) {
            if (pendingResult == null) return

            if (data != null) {
                // UPI apps return the response in the "response" extra or just dataString
                val response = data.getStringExtra("response") ?: "result_missing"
                pendingResult?.success(response)
            } else {
                // User cancelled or no data returned
                pendingResult?.success("cancelled")
            }
            pendingResult = null
        }
    }
}
