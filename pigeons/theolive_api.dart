import 'package:pigeon/pigeon.dart';

//run in the root folder: flutter pub run pigeon --input pigeons/theolive_api.dart

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/pigeon/theolive_api.g.dart',
  dartOptions: DartOptions(),
  kotlinOut: 'android/app/src/main/kotlin/live/theo/theolive_flutter_sample/bindings/pigeon/THEOliveAPI.g.kt',
  kotlinOptions: KotlinOptions(
    package: 'live.theo.theolive_flutter_sample.bindings.pigeon'
  ),
  swiftOut: 'ios/Runner/Bindings/pigeon/THEOliveAPI.g.swift',
  swiftOptions: SwiftOptions(),
  dartPackageName: 'theolive_flutter_sample',
))


//Talking to the native
@HostApi()
abstract class THEOliveNativeAPI {

  @async
  void loadChannel(String channelID);

  void play();

  void pause();

  void manualDispose();
}

//Native talks to Dart

@FlutterApi()
abstract class THEOliveFlutterAPI {
  void onChannelLoadedEvent(String channelID);
  void onPlaying();
}
