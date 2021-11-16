package com.acmesoftware.vouched

import android.app.Activity
import androidx.lifecycle.Lifecycle
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.engine.plugins.lifecycle.FlutterLifecycleAdapter
import io.flutter.plugin.common.EventChannel

object Shared {
    var binding: ActivityPluginBinding? = null

    fun getActivity(): Activity? {
        return binding?.activity
    }

    fun getLifecycle(): Lifecycle? {
        if (binding != null) {
            return FlutterLifecycleAdapter.getActivityLifecycle(binding!!)
        }
        return null
    }
}