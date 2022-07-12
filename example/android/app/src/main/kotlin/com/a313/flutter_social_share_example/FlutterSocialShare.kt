package com.a313.flutter_social_share_example

import android.app.Activity
import android.net.Uri
import androidx.annotation.NonNull
import com.facebook.CallbackManager
import com.facebook.FacebookCallback
import com.facebook.FacebookException
import com.facebook.share.Sharer
import com.facebook.share.model.ShareLinkContent
import com.facebook.share.widget.ShareDialog
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class FlutterSocialShare : FlutterPlugin, MethodChannel.MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel : MethodChannel
    lateinit var callbackManager: CallbackManager
    lateinit var activity: Activity

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_social_share")
        channel.setMethodCallHandler(this)
        callbackManager = CallbackManager.Factory.create()
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        if (call.method == "shareToFacebook") {
            val quote = call.argument<String>("quote")
            val url = call.argument<String>("url")
            shareToFacebook(url!!, quote!!, result)
        }
    }

    /**
     * share to Facebook
     *
     * @param url    String
     * @param msg    String
     * @param result Result
     */
    private fun shareToFacebook(url: String, msg: String, result: MethodChannel.Result) {
        val shareDialog = ShareDialog(activity)
        // this part is optional
        shareDialog.registerCallback(
            callbackManager,
            object : FacebookCallback<Sharer.Result>{
                override fun onCancel() {

                }

                override fun onError(error: FacebookException) {

                }

                override fun onSuccess(result: Sharer.Result) {

                }


            })
        val content: ShareLinkContent = ShareLinkContent.Builder()
            .setContentUrl(Uri.parse(url))
            .setQuote(msg)
            .build()
        if (ShareDialog.canShow(ShareLinkContent::class.java)) {
            shareDialog.show(content)
            result.success("success")
        }
    }

    fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.getActivity()
    }

    fun onDetachedFromActivityForConfigChanges() {}

    fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.getActivity()
    }


    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}