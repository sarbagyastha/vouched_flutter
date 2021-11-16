package com.acmesoftware.vouched

import android.content.Context
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.view.View
import androidx.camera.view.PreviewView
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleOwner
import id.vouched.android.*
import id.vouched.android.exception.VouchedAssetsMissingException
import id.vouched.android.exception.VouchedCameraHelperException
import id.vouched.android.model.JobResponse
import id.vouched.android.model.Params
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.platform.PlatformView
import kotlin.collections.*


internal class DetectorView(
    methodChannel: MethodChannel,
    eventChannel: EventChannel,
    context: Context,
    creationParams: Map<String, Any>
) :
    PlatformView, CardDetect.OnDetectResultListener, VouchedSession.OnJobResponseListener,
    PluginRegistry.RequestPermissionsResultListener, MethodChannel.MethodCallHandler,
    EventChannel.StreamHandler, DefaultLifecycleObserver {

    private val permissionRequestCode = 1

    private val platformViewContext: Context = context
    private val channel: MethodChannel = methodChannel
    private val previewView: PreviewView = PreviewView(context)
    private val session: VouchedSession = VouchedSession(creationParams["api_key"] as String)
    private var cameraHelper: VouchedCameraHelper? = null
    private val lifecycle = Shared.getLifecycle()
    private var eventSink: EventChannel.EventSink? = null

    init {
        lifecycle?.addObserver(this)
        eventChannel.setStreamHandler(this)
    }

    override fun onCreate(owner: LifecycleOwner) {
        super.onCreate(owner)
        channel.setMethodCallHandler(this)
        try {
            cameraHelper = VouchedCameraHelper(
                platformViewContext,
                owner,
                ContextCompat.getMainExecutor(platformViewContext),
                previewView,
                VouchedCameraHelper.Mode.ID,
                VouchedCameraHelperOptions.Builder()
                    .withCardDetectOptions(
                        CardDetectOptions.Builder()
                            .withEnableDistanceCheck(false)
                            .build()
                    )
                    .withCardDetectResultListener(this)
                    .build()
            )
        } catch (e: VouchedAssetsMissingException) {
            e.printStackTrace()
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when(call.method){
            "pauseCamera" -> {
                pauseCamera()
                result.success(null)
            }
            "resumeCamera" -> {
                resumeCamera()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    override fun onPause(owner: LifecycleOwner) {
        pauseCamera()
        super.onPause(owner)
    }

    override fun onResume(owner: LifecycleOwner) {
        super.onResume(owner)
        resumeCamera()
    }

    override fun onCardDetectResult(result: CardDetectResult) {
        try {
            val successData = HashMap<String, Any?>()
            with(result) {
                successData["step"] = step.name
                successData["instruction"] = instruction.name
                successData["image"] = image
                location?.let {
                    successData["location"] = mapOf(
                        "l" to it.left,
                        "t" to it.top,
                        "r" to it.right,
                        "b" to it.bottom
                    )
                }
            }
            eventSink?.success(successData)

            if (Step.POSTABLE == result.step) {
                pauseCamera()
                session.postFrontId(
                    platformViewContext,
                    result,
                    Params.Builder(),
                    this
                )
            }
        } catch (e: Exception) {
            eventSink?.error("", e.message, "")
        }
    }

    override fun onJobResponse(response: JobResponse) {
        with(response) {
            if (error == null) {
                channel.invokeMethod("success", response.job.toJson())
            } else {
                channel.invokeMethod("error", error.message)
            }
        }

    }



    override fun getView(): View {
        return previewView
    }

    override fun dispose() {
        lifecycle?.removeObserver(this)
    }


    override fun onListen(arguments: Any?, sink: EventChannel.EventSink?) {
        eventSink = sink
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    private fun pauseCamera() {
        cameraHelper!!.onPause()
    }

    private fun resumeCamera() {
        if (!hasAllRequiredPermission()) {
            requestPermissions()
        } else {
            try {
                cameraHelper!!.onResume()
            } catch (e: VouchedCameraHelperException) {
                e.printStackTrace()
            }
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>?,
        grantResults: IntArray?
    ): Boolean {
        if (requestCode != permissionRequestCode) return false
        if (hasAllRequiredPermission()) resumeCamera()
        return true
    }

    private fun getRequiredPermissions(): Array<String?> {
        return try {
            val info: PackageInfo = platformViewContext.packageManager
                .getPackageInfo(platformViewContext.packageName, PackageManager.GET_PERMISSIONS)
            val requestedPermissions = info.requestedPermissions
            if (requestedPermissions != null && requestedPermissions.isNotEmpty()) {
                requestedPermissions
            } else {
                arrayOfNulls(0)
            }
        } catch (e: Exception) {
            arrayOfNulls(0)
        }
    }

    private fun isPermissionGranted(permission: String?): Boolean {
        if (permission == null) return true

        val permissionStatus = ContextCompat.checkSelfPermission(platformViewContext, permission)
        return permissionStatus == PackageManager.PERMISSION_GRANTED
    }

    private fun hasAllRequiredPermission(): Boolean {
        return getRequiredPermissions().all { isPermissionGranted(it) }
    }

    private fun requestPermissions() {
        val allNeededPermissions: MutableList<String> = ArrayList()
        for (permission in getRequiredPermissions()) {
            if (permission != null && !isPermissionGranted(permission)) {
                allNeededPermissions.add(permission)
            }
        }
        if (allNeededPermissions.isNotEmpty()) {
            Shared.getActivity()?.let {
                ActivityCompat.requestPermissions(
                    it,
                    allNeededPermissions.toTypedArray(),
                    permissionRequestCode
                )
            }
        }
    }
}