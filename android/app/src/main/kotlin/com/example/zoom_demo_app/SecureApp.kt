package com.example.zoom_demo_app

import android.app.Activity
import android.app.Application
import android.os.Bundle
import android.view.WindowManager
import io.flutter.app.FlutterApplication

// Ensures FLAG_SECURE is applied to every Activity, including Zoom SDK activities.
class SecureApp : FlutterApplication(), Application.ActivityLifecycleCallbacks {
    override fun onCreate() {
        super.onCreate()
        registerActivityLifecycleCallbacks(this)
    }

    private fun secure(activity: Activity) {
        try {
            activity.window?.setFlags(
                WindowManager.LayoutParams.FLAG_SECURE,
                WindowManager.LayoutParams.FLAG_SECURE
            )
        } catch (_: Exception) { }
    }

    override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) { secure(activity) }
    override fun onActivityStarted(activity: Activity) { secure(activity) }
    override fun onActivityResumed(activity: Activity) { secure(activity) }
    override fun onActivityPaused(activity: Activity) {}
    override fun onActivityStopped(activity: Activity) {}
    override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {}
    override fun onActivityDestroyed(activity: Activity) {}
}
