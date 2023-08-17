package live.theo.theolive_flutter_sample

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import live.theo.theolive_flutter_sample.bindings.THEOliveViewFactory

class MainActivity: FlutterFragmentActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.getPlatformViewsController().getRegistry().registerViewFactory("theoliveview", THEOliveViewFactory(flutterEngine.dartExecutor.binaryMessenger))
    }
}
