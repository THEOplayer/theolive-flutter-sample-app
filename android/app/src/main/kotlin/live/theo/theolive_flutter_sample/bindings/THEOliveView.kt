package live.theo.theolive_flutter_sample.bindings

import android.content.Context
import android.util.Log
import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.platform.ViewCompositionStrategy
import com.theolive.player.api.*
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.platform.PlatformView
import kotlinx.coroutines.runBlocking


class THEOliveView(context: Context, viewId: Int, args: Any?, messenger: BinaryMessenger) : PlatformView,
    MethodChannel.MethodCallHandler, EventListener {

    private val cv: ComposeView
    private lateinit var player: THEOlivePlayer
    private val constraintLayout: LinearLayout

    private val methodChannel: MethodChannel


    init {

        constraintLayout = LinearLayout(context)

        val layoutParams = ViewGroup.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT)
        constraintLayout.layoutParams = layoutParams

        constraintLayout.id = viewId
        cv = ComposeView(context)
        cv.id = View.generateViewId();
        constraintLayout.addView(cv)

        cv.setViewCompositionStrategy(ViewCompositionStrategy.DisposeOnViewTreeLifecycleDestroyed)
        cv.setContent {
            val scope = rememberCoroutineScope()
            val player = rememberTHEOlivePlayer()

            this.player = player

            THEOliveChromeless(modifier = Modifier.fillMaxSize(), player = player)

            player.addEventListener(this);

        }

        methodChannel = MethodChannel(messenger, "THEOliveView/$viewId")
        methodChannel.setMethodCallHandler(this)

    }

    override fun onChannelLoaded(channelInfo: ChannelInfo) {
        Log.d("THEOliveView", "onChannelLoaded:");

        super.onChannelLoaded(channelInfo)
        //NOTE: instead of null, we can pass a result callback, if we care about a response from the receiver side too
        methodChannel.invokeMethod("onChannelLoaded", channelInfo.channelId, null)
    }


    override fun getView(): View? {
        return constraintLayout
    }

    override fun dispose() {
        //TODO("Not yet implemented")
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        // receive calls from Dart
        Log.d("THEOliveView", "onMethodCall: $call.method");

        when (call.method) {
            "loadChannel" -> {
                val channelId = call.argument<String>("channelId");
                Log.d("THEOliveView", "channelId: $channelId");
                Log.d("THEOliveView", "player: $player");
                channelId?.let {
                    //TODO: check this
                    runBlocking {
                        Log.d("THEOliveView", "player: $player");
                        player.loadChannel(channelId = it)
                    }
                    result.success(null)
                } ?: {
                    result.error("ERROR_1", "Missing channelId!", null)
                }
            }
            else -> { // Note the block
                result.notImplemented()
            }
        }
    }

}