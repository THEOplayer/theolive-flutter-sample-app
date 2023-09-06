import 'dart:io';

import 'package:flutter/material.dart';
import 'package:theolive_flutter_sample/theolive_view.dart';
import 'package:theolive_flutter_sample/theolive_view_controller.dart';

class FullscreenPage extends StatefulWidget {
  const FullscreenPage({super.key, required this.playerWidget});
  //const FullscreenPage({super.key, required this.playerViewKey});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  //TODO: check what's the best way of passing views.
  //final Key playerViewKey;
  final THEOliveView playerWidget;

  @override
  State<FullscreenPage> createState() => _FullscreenPageState();
}

class _FullscreenPageState extends State<FullscreenPage> {
  late THEOliveViewController _theoController;

  bool playing = false;

  late THEOliveView theoLiveView;

  @override
  void initState() {
    print("_FullscreenPageState with THEOliveView: initState ");
    super.initState();

    /*
    theoLiveView = THEOliveView(key: widget.playerViewKey, onTHEOliveViewCreated:(THEOliveViewController controller) {
      print("_FullscreenPageState with THEOliveView: onTHEOliveViewCreated ");

      // assign the controller to interact with the player
      _theoController = controller;
      _theoController.eventListener = this;

    }
    );
     */


    theoLiveView = widget.playerWidget;
    _theoController = theoLiveView.viewController;

  }

  @override
  void dispose() {
    print("_FullscreenPageState with THEOliveView: dispose ");
    // TODO: implement dispose
    super.dispose();
  }

  void _playPause() {
    bool newState = false;
    if (playing) {
      _theoController.pause();
      newState = false;
    } else {
      _theoController.play();
      newState = true;
    }
    setState(() {
      playing = newState;
    });
  }

  bool willPop = false;

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return CustomWillPopScope(
      onWillPop: () async {
        print("_FullscreenPageState with THEOliveView: onWillPop ");
        setState(() {
          willPop = true;
        });
        return true;
      },
      child: Scaffold(
        body: OrientationBuilder(
          builder: (BuildContext context, Orientation orientation) {
            //check orientation variable to identify the current mode
            //double w = MediaQuery.of(context).size.width;
            //double h = MediaQuery.of(context).size.height;
            //bool landscape = false;

            return Center(
                // Center is a layout widget. It takes a single child and positions it
                // in the middle of the parent.
                child: !willPop ? theoLiveView : Container());
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _playPause,
          tooltip: 'Load',
          child:
              playing ? const Icon(Icons.pause) : const Icon(Icons.play_arrow),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }
}

// Custom WillPopScope, because the original WillPopScope breaks the back navigation on iOS
class CustomWillPopScope extends StatelessWidget {
  CustomWillPopScope({required this.child, required this.onWillPop, Key? key})
      : super(key: key);

  final Widget child;
  final WillPopCallback onWillPop;

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? GestureDetector(
            onPanUpdate: (details) async {
              if (details.delta.dx > 0) {
                if (await onWillPop()) {
                  Navigator.of(context).pop();
                }
              }
            },
            child: WillPopScope(
              onWillPop: () async {
                return false;
              },
              child: child,
            ))
        : WillPopScope(child: child, onWillPop: onWillPop);
  }
}
