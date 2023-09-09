package live.theo.theolive_flutter_sample.bindings

import android.content.Context
import android.util.Log
import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Surface
import androidx.compose.runtime.derivedStateOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.ComposeView
import com.theolive.player.api.EventListener
import com.theolive.player.api.THEOliveChromeless
import com.theolive.player.api.THEOlivePlayer
import com.theolive.player.api.rememberTHEOlivePlayer
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.platform.PlatformView
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.CoroutineStart
import kotlinx.coroutines.Deferred
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.async
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import live.theo.theolive_flutter_sample.bindings.pigeon.THEOliveFlutterAPI
import live.theo.theolive_flutter_sample.bindings.pigeon.THEOliveNativeAPI


class THEOliveView(context: Context, viewId: Int, args: Any?, messenger: BinaryMessenger) : PlatformView,
    EventListener, THEOliveNativeAPI {

    private val cv: ComposeView
    private var player: THEOlivePlayer? = null

    private val constraintLayout: LinearLayout

    private val flutterApi: THEOliveFlutterAPI

    private var loadChannelJob: Deferred<Unit>? = null


    // Workaround to eliminate the inital transparent layout with ComposeView
    // TODO: remove it once Compose is not used.
    private var _isFirstPlaying = mutableStateOf(false);
    private var isFirstPlaying: Boolean
        get() = _isFirstPlaying.value
        set(value) { _isFirstPlaying.value = value }

    init {
        Log.d("THEOliveView", "init $viewId");

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

        // only change it if there are issues with the view lifecycle
        //cv.setViewCompositionStrategy(ViewCompositionStrategy.DisposeOnDetachedFromWindow)
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


            // workaround to hide the player until it is not playing.
            // player has to be present in the view hierarchy to start loading, so we can't dynamically add it for now
            // TODO: remove it once Compose is not used.
            val visibility by remember {
                derivedStateOf {
                    if (isFirstPlaying) {
                        1.0F
                    } else {
                        0.0F
                    }
                }
            }

            Surface(modifier = Modifier.fillMaxSize(), color = Color.Black) {
                THEOliveChromeless(modifier = Modifier.fillMaxSize().alpha(visibility), player = player)
            }

        }

    }

    override fun onChannelLoadStart(channelId: String) {
        Log.d("THEOliveView", "onChannelLoadStart: $channelId");
        isFirstPlaying = false

    }
    override fun onChannelLoaded(channelId: String) {
        Log.d("THEOliveView", "onChannelLoaded:");
        CoroutineScope(Dispatchers.Main).launch {
            flutterApi.onChannelLoadedEvent(channelId, callback = {
                Log.d("THEOliveView", "JAVA onChannelLoaded ack received: " +  channelId)
            });
        }
    }

    override fun onChannelOffline(channelId: String) {
        Log.d("THEOliveView", "onChannelOffline: $channelId");
    }

    override fun onPlaying() {
        Log.d("THEOliveView", "onPlaying");

        if (!isFirstPlaying) {
            isFirstPlaying = true
        }

        CoroutineScope(Dispatchers.Main).launch {
            flutterApi.onPlaying {
                Log.d("THEOliveView", "JAVA onPlaying ack received: ")
            }
        }
    }

    override fun onWaiting() {
        Log.d("THEOliveView", "onWaiting");
    }

    override fun onPause() {
        Log.d("THEOliveView", "onPause");
    }

    override fun onPlay() {
        Log.d("THEOliveView", "onPlay");
    }

    override fun onIntentToFallback() {
        Log.d("THEOliveView", "onIntentToFallback");
        isFirstPlaying = false
    }

    override fun onReset() {
        Log.d("THEOliveView", "onReset");
        isFirstPlaying = false
    }

    override fun onError(message: String) {
        Log.d("THEOliveView", "error: $message");
    }

    override fun getView(): View? {
        return constraintLayout
    }

    override fun dispose() {
        Log.d("THEOliveView", "dispose");
        loadChannelJob?.isActive.let {
            loadChannelJob?.cancel("DISPOSED", CancellationException("THEOliveView disposed!"))
        }
        player?.removeEventListener(this);
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

    override fun manualDispose() {
        Log.d("THEOliveView", "manualDispose");
        //DO NOTHING, normal dispose() flow should be called by Flutter
    }

    override fun play() {
        if (this.player == null) {
            Log.d("THEOliveView", "player is missing!");
            return
        }
        this.player!!.play();
    }

    override fun pause() {
        if (this.player == null) {
            Log.d("THEOliveView", "player is missing!");
            return
        }
        this.player!!.pause()
    }

}