import Flutter
import UIKit
import FBSDKShareKit
import FBSDKCoreKit

public class SwiftFlutterSocialSharePlugin: NSObject, FlutterPlugin, SharingDelegate {
    var result: FlutterResult?
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable: Any] = [:]) -> Bool {
        let launchOptionsForFacebook = launchOptions as? [UIApplication.LaunchOptionsKey: Any]
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions:
                launchOptionsForFacebook
        )
        return true
    }
    
    public func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return ApplicationDelegate.shared.application(application, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
    }
    
    public func application(_ application: UIApplication, open url: URL, sourceApplication: String, annotation: Any) -> Bool {
        return ApplicationDelegate.shared.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    @available(iOS 13.0, *)
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }
        
        ApplicationDelegate.shared.application(
            UIApplication.shared,
            open: url,
            sourceApplication: nil,
            annotation: [UIApplication.OpenURLOptionsKey.annotation]
        )
    }
    
    private func failedWithMessage(_ message: String) -> [String: Any] {
        return ["code": 0, "message": message]
    }
    
    private let succeeded = ["code": 1]
    private let cancelled = ["code": -1]
    
    public func sharer(_ sharer: Sharing, didCompleteWithResults results: [String : Any]) {
        self.result?(succeeded)
    }
    
    public func sharer(_ sharer: Sharing, didFailWithError error: Error) {
        self.result?(failedWithMessage(error.localizedDescription))
    }
    
    public func sharerDidCancel(_ sharer: Sharing) {
        self.result?(cancelled)
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        ApplicationDelegate.initialize()
        let channel = FlutterMethodChannel(name: "flutter_social_share", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterSocialSharePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addApplicationDelegate(instance)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "shareLinkToFacebook" {
            if let arguments = call.arguments as? [String:Any] {
                let shareQuote = arguments["quote"] as! String?
                let shareUrl = arguments["url"] as! String?
                let requiredApp = arguments ["requiredApp"] as? Bool ?? false
                shareLinkToFacebook(withQuote: shareQuote, withUrl:shareUrl, withApp:requiredApp)
            }
        }
    }
    
    
    private func shareLinkToFacebook(withQuote quote: String?, withUrl urlString: String?, withApp requiredApp: Bool) {
        
        if requiredApp {
            let installed = checkInstallFacebook()
            if installed {
                shareToFacebook(withQuote:quote,urlString:urlString)
            } else {
                openFacebookAppStore()
            }
        }else{
            shareToFacebook(withQuote:quote,urlString:urlString)
        }
    }
    
    
    private func shareToFacebook(withQuote quote: String?, urlString: String?)
    {
        let shareContent = ShareLinkContent()
        if let url = urlString {
            shareContent.contentURL = URL.init(string: url)!
        }
        if let quoteString = quote {
            shareContent.quote = quoteString
        }
        
        let dialog = ShareDialog(
            viewController: UIApplication.shared.delegate?.window??.rootViewController,
            content: shareContent,
            delegate: self
        )
        dialog.show()
    }
    
    func checkInstallFacebook() -> Bool {
        let fbURL = URL(string: "fbapi://")!
        if UIApplication.shared.canOpenURL(fbURL) {
            return true;
        }
        return false;
    }
    
    func openFacebookAppStore()  {
        let fbLink = "itms-apps://itunes.apple.com/us/app/apple-store/id284882215"
        if #available(iOS 10.0, *) {
            if let url = URL(string: fbLink) {
                UIApplication.shared.open(url, options: [:]) { _ in
                }
            }
        } else {
            if let url = URL(string: fbLink) {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
}
