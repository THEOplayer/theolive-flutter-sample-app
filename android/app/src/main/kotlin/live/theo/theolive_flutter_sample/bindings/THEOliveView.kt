package live.theo.theolive_flutter_sample.bindings

import android.content.Context
import android.util.Log
import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.platform.ViewCompositionStrategy
import com.theolive.player.api.*
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.platform.PlatformView
import kotlinx.coroutines.*
import live.theo.theolive_flutter_sample.bindings.pigeon.THEOliveFlutterAPI
import live.theo.theolive_flutter_sample.bindings.pigeon.THEOliveNativeAPI


class THEOliveView(context: Context, viewId: Int, args: Any?, messenger: BinaryMessenger) : PlatformView,
    EventListener, THEOliveNativeAPI {

    private val cv: ComposeView
    private var player: THEOlivePlayer? = null

    private val constraintLayout: LinearLayout

    private val flutterApi: THEOliveFlutterAPI

    private var loadChannelJob: Deferred<Unit>? = null

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
            val player = rememberTHEOlivePlayer()

            if (this.player == null) {
                this.player = player
                player.addEventListener(this);
            }

            //if we had a too early loadChannel call, it is deferred until this moment
            loadChannelJob?.let {
                loadChannelJob!!.start()
            }

            THEOliveChromeless(modifier = Modifier.fillMaxSize(), player = player)

        }

    }

    override fun onChannelLoaded(channelId: String) {
        Log.d("THEOliveView", "onChannelLoaded:");

        super.onChannelLoaded(channelId)
        CoroutineScope(Dispatchers.Main).launch {
            flutterApi.onChannelLoadedEvent(channelId, callback = {
                Log.d("THEOliveView", "JAVA onChannelLoaded ack received: " +  channelId)
            });
        }

    }

    override fun getView(): View? {
        return constraintLayout
    }

    override fun dispose() {
        loadChannelJob?.isActive.let {
            loadChannelJob?.cancel("DISPOSED", CancellationException("THEOliveView disposed!"))
        }
    }

    override fun loadChannel(channelID: String, callback: (Result<Unit>) -> Unit) {
        Log.d("THEOliveView", "loadChannel called, $channelID");

        loadChannelJob?.cancel("CANCELED", CancellationException("New channel loading started!"))

        loadChannelJob = MainScope().async(start = CoroutineStart.LAZY) {
            Log.d("THEOliveView", "loadChannel started: $channelID, player: $player");
            player!!.loadChannel(channelID)
        }

        loadChannelJob!!.invokeOnCompletion {
            Log.d("THEOliveView", "loadChannel completed, $it");
            loadChannelJob = null

            if (it == null) {
                callback(Result.success(Unit))
            } else {
                if (it is CancellationException) {
                    callback(Result.failure(it))
                } else {
                    // if it is not our exception, we throw it further
                    throw it
                }
            }
        }

        if (player == null) {
            Log.d("THEOliveView", "waiting for player, $channelID");
            return;
        }

        loadChannelJob!!.start()
    }

}