package com.example.zoom_demo_app

import android.content.Context
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import us.zoom.sdk.*

object ZoomHelper {
    private const val CHANNEL = "zoom_bridge" 

    // Hold application context for SDK calls that require it (e.g., joinMeetingWithParams)
    private lateinit var appContext: Context

    fun registerWith(flutterEngine: FlutterEngine, context: Context) {
        // Save application context
        appContext = context.applicationContext

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "init" -> {
                    val jwtToken = call.argument<String>("jwtToken")  
                    if (jwtToken.isNullOrEmpty()) {
                        result.error("ARGS", "Missing jwtToken", null)
                        return@setMethodCallHandler
                    }
                    initZoom(context, jwtToken, result)
                }
                "join" -> {  // Changed from "joinMeeting" to "join"
                    val meetingNumber = call.argument<String>("meetingNumber") ?: ""
                    val passcode = call.argument<String>("passcode") ?: ""
                    val displayName = call.argument<String>("displayName") ?: "Student"
                    joinMeeting(meetingNumber, passcode, displayName, result)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun initZoom(context: Context, jwt: String, cb: MethodChannel.Result) {
        val params = ZoomSDKInitParams().apply {
            jwtToken = jwt
            domain = "zoom.us"
            enableLog = true
        }

        ZoomSDK.getInstance().initialize(
            context,
            object : ZoomSDKInitializeListener {
                override fun onZoomSDKInitializeResult(errorCode: Int, internalErrorCode: Int) {
                    if (errorCode == ZoomError.ZOOM_ERROR_SUCCESS) {
                        cb.success(true)
                    } else {
                        cb.error("INIT", "Zoom init failed: $errorCode/$internalErrorCode", null)
                    }
                }
                override fun onZoomAuthIdentityExpired() {}
            },
            params
        )
    }

    private fun joinMeeting(meetingNumber: String, passcode: String, displayName: String, cb: MethodChannel.Result) {
        val sdk = ZoomSDK.getInstance()
        if (!sdk.isInitialized) {
            cb.error("JOIN", "SDK not initialized", null)
            return
        }

        // Ensure we have a valid Context for the SDK call
        if (!this::appContext.isInitialized) {
            cb.error("JOIN", "Context not ready", null)
            return
        }

        val meetingService = sdk.meetingService
        val options = JoinMeetingOptions()
        val joinParams = JoinMeetingParams().apply {
            this.displayName = displayName
            // Zoom expects only digits for meeting number
            this.meetingNo = meetingNumber.filter { it.isDigit() }
            this.password = passcode
        }

        val joinCode = meetingService.joinMeetingWithParams(appContext, joinParams, options)
        if (joinCode == MeetingError.MEETING_ERROR_SUCCESS) {
            cb.success(0) // Return 0 for success
        } else {
            cb.error("JOIN", "Join failed: $joinCode", null)
        }
    }
}