import 'package:theolive_flutter_sample/pigeon/theolive_api.g.dart';

class THEOliveViewController implements  THEOliveFlutterAPI{
  static const String _TAG = "FL_DART_THEOliveViewController";
  int _id;

  final THEOliveNativeAPI _nativeAPI = THEOliveNativeAPI();

  THEOliveViewController(this._id) {
    THEOliveFlutterAPI.setup(this);
  }

  // if we want to call async
  loadChannel(String channelId)  {
    _nativeAPI.loadChannel(channelId);
  }

  @override
  void onChannelLoadedEvent(String channelID) {
    print("$_TAG  onChannelLoaded received: $channelID");
  }

}