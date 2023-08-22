import 'package:flutter/cupertino.dart';
import 'package:theolive_flutter_sample/pigeon/theolive_api.g.dart';

class THEOliveViewController implements  THEOliveFlutterAPI{
  static const String _TAG = "FL_DART_THEOliveViewController";
  int _id;

  final THEOliveNativeAPI _nativeAPI = THEOliveNativeAPI();

  THEOliveViewController(this._id) {
    THEOliveFlutterAPI.setup(this);
  }

  void loadChannel(String channelId) {
    _nativeAPI.loadChannel(channelId).onError(
            //consume the exception, it is irrelevant to the flow, just for information
            (error, stackTrace) => print("ERROR during loadChannel: $error")
    );
  }

  @override
  void onChannelLoadedEvent(String channelID) {
    print("$_TAG  onChannelLoaded received: $channelID");
  }

}