
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class THEOliveViewController {
  static const String _TAG = "FL_DART_THEOliveViewController";
  late MethodChannel _channel;
  int _id;

  THEOliveViewController(this._id) {
    _channel = MethodChannel('THEOliveView/$_id');
    _channel.setMethodCallHandler(_handleMethod);
  }


  // handle calls from Android
  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'onChannelLoaded':
        dynamic channelId = call.arguments;
        if (kDebugMode) {
          print("$_TAG  onChannelLoaded received: $channelId");
        }
        return Future.value("ok"); // whatever, if we want to send back something
      default:
        print("$_TAG  unexpected received: ${call.method}");


    }

  }

  // if we want to call async
  loadChannel(String channelId)  {
    _channel.invokeMethod("loadChannel", { "channelId": channelId } );
  }

}