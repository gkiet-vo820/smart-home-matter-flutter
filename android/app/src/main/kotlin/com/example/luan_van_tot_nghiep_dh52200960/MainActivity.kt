package com.example.luan_van_tot_nghiep_dh52200960

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.kiet.smart_home_matter/matter"
    private val matterManager = MatterManager()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            try {
                when (call.method) {

                    "commissionDevice" -> {
                        val setupCode = call.argument<String>("setupCode") ?: ""

                        if (setupCode.isEmpty()) {
                            result.error(
                                "INVALID_SETUP_CODE",
                                "Mã setup không được để trống",
                                null
                            )
                            return@setMethodCallHandler
                        }

                        val deviceInfo = matterManager.commissionDevice(setupCode)
                        result.success(deviceInfo)
                    }

                    "toggleDevice" -> {
                        val deviceId = call.argument<String>("deviceId") ?: ""
                        val targetState = call.argument<Boolean>("targetState") ?: false

                        if (deviceId.isEmpty()) {
                            result.error(
                                "INVALID_DEVICE_ID",
                                "Device ID không hợp lệ",
                                null
                            )
                            return@setMethodCallHandler
                        }

                        val success = matterManager.toggleDevice(
                            deviceId = deviceId,
                            targetState = targetState
                        )

                        result.success(success)
                    }

                    else -> {
                        result.notImplemented()
                    }
                }
            } catch (e: Exception) {
                result.error(
                    "NATIVE_ERROR",
                    e.message ?: "Lỗi không xác định từ Kotlin",
                    null
                )
            }
        }
    }
}