import Flutter
import UIKit
import FBSDKShareKit

public class SwiftFlutterSocialSharePlugin: NSObject, FlutterPlugin, SharingDelegate {
    public func sharer(_ sharer: Sharing, didCompleteWithResults results: [String : Any]) {
        
    }
    
    public func sharer(_ sharer: Sharing, didFailWithError error: Error) {
        
    }
    
    public func sharerDidCancel(_ sharer: Sharing) {
        
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_social_share", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterSocialSharePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "shareToFacebook" {
            if let arguments = call.arguments as? [String:Any] {                
                var shareQuote = arguments["quote"] as! String
                var shareUrl = arguments["url"] as! String
                shareToFacebook(withQuote: shareQuote, withUrl:shareUrl)
            }
        }
    }
    var result: FlutterResult?
    
    private func shareToFacebook(withQuote quote: String?, withUrl urlString: String?) {
        DispatchQueue.main.async {
            let shareContent = ShareLinkContent()
            if let url = urlString {
                shareContent.contentURL = URL.init(string: url)!
            }
            if let quoteString = quote {
                shareContent.quote = quoteString
            }
            if let flutterAppDelegate = UIApplication.shared.delegate as? FlutterAppDelegate {
                let shareDialog = ShareDialog(
                    viewController: flutterAppDelegate.window.rootViewController,
                    content: shareContent,
                    delegate: self
                )
                shareDialog.mode = .automatic
                shareDialog.show()
                self.result?("Success")
            } else{
                self.result?("Failure")
            }
        }
    }
}
