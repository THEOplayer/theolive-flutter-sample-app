package live.theo.theolive_flutter_sample.bindings

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MessageCodec
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class THEOliveViewFactory(createArgsCodec: MessageCodec<Any>?) :
    PlatformViewFactory(createArgsCodec) {

    lateinit var messenger: BinaryMessenger

    constructor(messenger: BinaryMessenger) : this(StandardMessageCodec.INSTANCE) {
        this.messenger = messenger
    }

    override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
        return THEOliveView(context!!, viewId, args, messenger);
    }
}