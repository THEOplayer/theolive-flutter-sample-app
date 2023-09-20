import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:theolive_flutter_sample/theolive_view_controller.dart';

class THEOliveView extends StatefulWidget {

  final Function(THEOliveViewController) onTHEOliveViewCreated;

  THEOliveView({required Key key, required this.onTHEOliveViewCreated,}) : super(key: key);

  late THEOliveViewController viewController;

  @override
  State<StatefulWidget> createState() {
    return _THEOliveViewState();
  }

}

class _THEOliveViewState extends State<THEOliveView> {

  late THEOliveViewController viewController;

  @override
  void initState() {
    print("_THEOliveViewState initState");
    super.initState();
  }

  @override
  void dispose() {
    print("_THEOliveViewState dispose");
    // NOTE: this would be nicer, if we move it inside the THEOliveView that's a StatefulWidget
    // FIX for https://github.com/flutter/flutter/issues/97499
    viewController.manualDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("_THEOliveViewState build");

    // This is used in the platform side to register the view.
    const String viewType = 'theoliveview';
    // Pass parameters to the platform side.
    const Map<String, dynamic> creationParams = <String, dynamic>{};

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return PlatformViewLink(
          viewType: viewType,
          surfaceFactory:
              (context, controller) {
            return AndroidViewSurface(
              controller: controller as AndroidViewController,
              gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{
              },
              hitTestBehavior: PlatformViewHitTestBehavior.opaque,
            );
          },
          onCreatePlatformView: (params) {
            return PlatformViewsService.initAndroidView(
              id: params.id,
              viewType: viewType,
              layoutDirection: TextDirection.ltr,
              creationParams: creationParams,
              creationParamsCodec: const StandardMessageCodec(),
              onFocus: () {
                params.onFocusChanged(true);
              },
            )
              ..addOnPlatformViewCreatedListener((id) {
                print("_THEOliveViewState OnPlatformViewCreatedListener");
                params.onPlatformViewCreated(id);
                viewController = THEOliveViewController(id);
                widget.viewController = viewController;
                widget.onTHEOliveViewCreated(viewController);
              })
              ..create();
          },
        );
      case TargetPlatform.iOS:
        return UiKitView(
            viewType: viewType,
            layoutDirection: TextDirection.ltr,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
            onPlatformViewCreated: (id) {
              print("_THEOliveViewState OnPlatformViewCreatedListener");
              viewController = THEOliveViewController(id);
              widget.viewController = viewController;
              widget.onTHEOliveViewCreated(viewController);
            }
        );
      default:
        return Text("Unsupported platform $defaultTargetPlatform");
    }
  }

  @override
  void didChangeDependencies() {
    print("_THEOliveViewState didChangeDependencies");
    super.didChangeDependencies();
  }

  @override
  void activate() {
    print("_THEOliveViewState activate");
    super.activate();
  }

  @override
  void deactivate() {
    print("_THEOliveViewState deactivate");
    super.deactivate();
  }

  @override
  void reassemble() {
    print("_THEOliveViewState reassemble");
    super.reassemble();
  }
}
