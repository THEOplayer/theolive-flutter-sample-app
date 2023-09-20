package live.theo.theolive_flutter_sample.bindings

import android.content.Context
import android.util.Log
import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import com.theolive.player.EventListener
import com.theolive.player.PlayerView
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.platform.PlatformView
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import live.theo.theolive_flutter_sample.bindings.pigeon.THEOliveFlutterAPI
import live.theo.theolive_flutter_sample.bindings.pigeon.THEOliveNativeAPI


class THEOliveView(context: Context, viewId: Int, args: Any?, messenger: BinaryMessenger) : PlatformView,
    EventListener, THEOliveNativeAPI {

    private var playerView: PlayerView

    private val constraintLayout: LinearLayout

    private val flutterApi: THEOliveFlutterAPI

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
        playerView = PlayerView(context)
        playerView.id = View.generateViewId()
        playerView.layoutParams = layoutParams
        constraintLayout.addView(playerView)

        playerView.player.addEventListener(this)

    }

    override fun onChannelLoadStart(channelId: String) {
        Log.d("THEOliveView", "onChannelLoadStart: $channelId");

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
    }

    override fun onReset() {
        Log.d("THEOliveView", "onReset");
    }

    override fun onError(message: String) {
        Log.d("THEOliveView", "error: $message");
    }

    override fun getView(): View? {
        return constraintLayout
    }

    override fun dispose() {
        Log.d("THEOliveView", "dispose");

        playerView.player.removeEventListener(this);
        constraintLayout.removeView(playerView)
        playerView.onDestroy()
    }

    override fun loadChannel(channelID: String, callback: (Result<Unit>) -> Unit) {
        Log.d("THEOliveView", "loadChannel called, $channelID");
        playerView.player.loadChannel(channelID);
    }

    override fun manualDispose() {
        Log.d("THEOliveView", "manualDispose");
        //DO NOTHING, normal dispose() flow should be called by Flutter
    }

    override fun play() {
        this.playerView.player.play();
    }

    override fun pause() {
        this.playerView.player.pause()
    }

}
