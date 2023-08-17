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
import io.flutter.plugin.platform.PlatformView
import kotlinx.coroutines.runBlocking
import live.theo.theolive_flutter_sample.bindings.pigeon.THEOliveFlutterAPI
import live.theo.theolive_flutter_sample.bindings.pigeon.THEOliveNativeAPI


class THEOliveView(context: Context, viewId: Int, args: Any?, messenger: BinaryMessenger) : PlatformView,
    EventListener, THEOliveNativeAPI {

    private val cv: ComposeView
    private lateinit var player: THEOlivePlayer
    private val constraintLayout: LinearLayout

    private val flutterApi: THEOliveFlutterAPI

    init {

        THEOliveNativeAPI.setUp(messenger, this);
        flutterApi = THEOliveFlutterAPI(messenger);

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

    }

    override fun onChannelLoaded(channelInfo: ChannelInfo) {
        Log.d("THEOliveView", "onChannelLoaded:");

        super.onChannelLoaded(channelInfo)
        flutterApi.onChannelLoadedEvent(channelInfo.channelId, callback = {
            Log.d("THEOliveView", "JAVA onChannelLoaded ack received: " + (channelInfo.channelId))
        });
    }


    override fun getView(): View? {
        return constraintLayout
    }

    override fun dispose() {
        //TODO("Not yet implemented")
    }

    override fun loadChannel(channelID: String) {
        runBlocking {
            Log.d("THEOliveView", "loadChannel: $channelID, player: $player");
            player.loadChannel(channelID)
        }
    }

}