import 'dart:async';

import 'package:flutter/services.dart';

typedef OnCancel = Future<void> Function();
typedef OnError = Future<void> Function(String error);
typedef OnSuccess = Future<void> Function(String postId);

class FlutterSocialShare {
  static const MethodChannel _channel = MethodChannel('flutter_social_share');

  static Future<void> shareLinkToFacebook({
    String? quote,
    String? url,
    bool requiredApp = false,
    OnSuccess? onSuccess,
    OnCancel? onCancel,
    OnError? onError,
  }) async {
    final Map<String, dynamic> params = <String, dynamic>{
      "quote": quote,
      "url": url,
      "requiredApp": requiredApp
    };

    _channel.setMethodCallHandler((call) {
      switch (call.method) {
        case "onSuccess":
          return onSuccess?.call(call.arguments) ?? Future.value();
        case "onCancel":
          return onCancel?.call() ?? Future.value();
        case "onError":
          return onError?.call(call.arguments) ?? Future.value();
        default:
          throw UnsupportedError("Unknown method called");
      }
    });
    return _channel.invokeMethod('shareLinkToFacebook', params);
  }
}
