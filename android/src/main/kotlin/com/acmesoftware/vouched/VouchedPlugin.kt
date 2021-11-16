package com.acmesoftware.vouched

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/** VouchedPlugin */
class VouchedPlugin : FlutterPlugin, ActivityAware {

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        val messenger = binding.binaryMessenger
        val viewFactory = DetectorViewFactory(
            MethodChannel(messenger, "com.acmesoftware.vouched"),
            EventChannel(messenger, "com.acmesoftware.vouched/event")
        )

        binding
            .platformViewRegistry
            .registerViewFactory("com.acmesoftware.vouched/detector", viewFactory)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {}

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        Shared.binding = binding
    }

    override fun onDetachedFromActivityForConfigChanges() {
        Shared.binding = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        Shared.binding = binding
    }

    override fun onDetachedFromActivity() {
        Shared.binding = null

    }
}
