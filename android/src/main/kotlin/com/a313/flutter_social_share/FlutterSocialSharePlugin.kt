package com.a313.flutter_social_share

import androidx.annotation.NonNull
import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import com.facebook.CallbackManager
import com.facebook.FacebookCallback
import com.facebook.FacebookException
import com.facebook.share.Sharer
import com.facebook.share.model.ShareLinkContent
import com.facebook.share.widget.ShareDialog
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener

private const val FACEBOOK_PACKAGE_NAME = "com.facebook.katana"

/** FlutterSocialSharePlugin */
class FlutterSocialSharePlugin: FlutterPlugin, ActivityAware, MethodCallHandler, ActivityResultListener  {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var activity: Activity
  private lateinit var channel : MethodChannel
  private lateinit var callbackManager: CallbackManager
  


  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_social_share")
    channel.setMethodCallHandler(this)
    callbackManager = CallbackManager.Factory.create()
  }  

 override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    binding.addActivityResultListener(this)
    activity = binding.getActivity()
  }

override  fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    binding.addActivityResultListener(this)
    activity = binding.getActivity()
  }

    override fun onDetachedFromActivityForConfigChanges() {
//    binding.removeActivityResultListener(this)
  }

  override fun onDetachedFromActivity() {
//    binding.removeActivityResultListener(this)
  }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
     return callbackManager.onActivityResult(requestCode, resultCode, data)
   }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
    val pm = this.activity!!.packageManager
    if (call.method == "shareLinkToFacebook") {
      var quote:String? = call.argument("quote")
      var  url:String? = call.argument("url")
      var requiredApp:Boolean? = call.argument("requiredApp")
        var required = requiredApp ?: true;
      shareLinkToFacebook(url, quote, required,result)
    }
  }

   private fun openPlayStore(packageName: String) {
    try {
      val playStoreUri = Uri.parse("market://details?id=$packageName")
      val intent = Intent(Intent.ACTION_VIEW, playStoreUri)
      activity!!.startActivity(intent)
    } catch (e: ActivityNotFoundException) {
      val playStoreUri = Uri.parse("https://play.google.com/store/apps/details?id=$packageName")
      val intent = Intent(Intent.ACTION_VIEW, playStoreUri)
      activity!!.startActivity(intent)
    }
  }

  private fun shareLinkToFacebook(url: String?, quote: String?, requiredApp: Boolean, result: MethodChannel.Result) {
    if(requiredApp){
       val pm = activity!!.packageManager
       try{
        pm.getPackageInfo(FACEBOOK_PACKAGE_NAME, PackageManager.GET_ACTIVITIES)
        shareToFacebook(quote,url,result)
       }catch (e: PackageManager.NameNotFoundException) {
        openPlayStore(FACEBOOK_PACKAGE_NAME)
        result.success(false)
      }
    }else{
      shareToFacebook(quote,url,result)
    }

  }
private fun shareToFacebook(quote: String?, url: String?,result: MethodChannel.Result){
    val uri = Uri.parse(url)
    val content: ShareLinkContent = ShareLinkContent.Builder().setContentUrl(uri).setQuote(quote).build()
    val shareDialog = ShareDialog(activity)
   shareDialog.registerCallback(
    callbackManager ,
    object : FacebookCallback<Sharer.Result> {
      override fun onSuccess(result: Sharer.Result) {
        val a = 2+2;
      }

      override fun onCancel() {
      
        val a = 2+2;
      }



        override fun onError(error: FacebookException) {
            TODO("Not yet implemented")
        }
    })
    if (ShareDialog.canShow(ShareLinkContent::class.java)) {
      shareDialog.show(content)
    }
  }
}
