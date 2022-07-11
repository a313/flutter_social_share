import 'dart:async';

import 'package:flutter/services.dart';

class FlutterSocialShare {
  static const MethodChannel _channel = MethodChannel('flutter_social_share');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String?> shareToFacebook(
      {String? quote, String? url, String? imageName, String? imageUrl}) async {
    final Map<String, dynamic> params = <String, dynamic>{
      "quote": quote,
      "url": url,
      "imageName": imageName,
      "imageUrl": imageUrl
    };
    final String? message =
        await _channel.invokeMethod('shareToFacebook', params);
    return message;
  }
}
