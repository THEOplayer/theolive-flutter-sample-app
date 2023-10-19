//
//  THEOliveView.swift
//  flutter_theolive
//
//  Created by Daniel on 16/07/2023.
//

import Foundation
import Flutter
import UIKit
import THEOliveSDK
import os

let log = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "com.theoplayer.THEOliveViewSample" , category: "THEOliveView")

class THEOliveView: NSObject, FlutterPlatformView, THEOlivePlayerEventListener, THEOliveNativeAPI {
    
    private static var TAG = "FL_IOS_THEOliveView"
    private var _view: UIView
    private let _viewId: Int64
    private let _flutterAPI: THEOliveFlutterAPI
    private let player = THEOliveSDK.THEOlivePlayer()

    var newPlayerView: THEOliveSDK.THEOliveChromelessPlayerView?
    
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        _viewId = viewId
        _view = UIView()
        _view.frame = frame
        _flutterAPI = THEOliveFlutterAPI(binaryMessenger: messenger!)

        super.init()
        
        THEOliveNativeAPISetup.setUp(binaryMessenger: messenger!, api: self)

        // iOS views can be created here
        createNativeView(view: _view)
        setupEventListeners()
         
    }
    

    func view() -> UIView {
        return _view
    }
    
    func createNativeView(view _view: UIView){
        _view.backgroundColor = UIColor.yellow

        let newPlayerView = THEOliveSDK.THEOliveChromelessPlayerView(player: player)

        newPlayerView.translatesAutoresizingMaskIntoConstraints = false
        newPlayerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        newPlayerView.frame = _view.bounds

        _view.addSubview(newPlayerView)
        
        self.newPlayerView = newPlayerView

    }
    
    func setupEventListeners() {
        
        player.add(eventListener: self)
        
    }
    
    // THEOliveNativeAPI
    func loadChannel(channelID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        os_log("loadChannel API call", log: log, type: .debug)
        self.player.loadChannel(channelID)
        completion(Result.success({}()))
    }
    
    func play() throws {
        self.player.play()
    }
    
    func pause() throws {
        self.player.pause()
    }
    
    func preloadChannels(channelIDs: [String]) throws {
        self.player.preloadChannels(channelIDs)
    }
    
    
    // Fix for https://github.com/flutter/flutter/issues/97499
    // The PlatformViews are not deallocated in time, so we clean up upfront.
    func manualDispose() throws {
        os_log("manualDispose", log: log, type: .debug)
        player.remove(eventListener: self)
        newPlayerView?.removeFromSuperview()
        player.reset()
                
    }
    
    // THEOlivePlayerEventListener
    func onChannelLoaded(channelId: String) {
        os_log("onChannelLoaded: %@", log: log, type: .debug, channelId)
        _flutterAPI.onChannelLoadedEvent(channelID: channelId) {
            os_log("onChannelLoaded ack received: %@", log: log, type: .debug, channelId)
        }
    }
    
    func onPlaying() {
        os_log("onPlaying", log: log, type: .debug)
        _flutterAPI.onPlaying {
           os_log("onPlaying ack received", log: log, type: .debug)
        }
    }
    
    func onError(message: String) {
        os_log("onError: %@" , log: log, type: .debug, message)
    }
    
    func onChannelOffline(channelId: String) {
        os_log("onChannelOffline: %@" , log: log, type: .debug, channelId)
    }
    
    func onChannelLoadStart(channelId: String) {
        os_log("onChannelLoadStart: %@" , log: log, type: .debug, channelId)
    }
    
    func onWaiting() {
        os_log("onWaiting", log: log, type: .debug)
    }
    
    func onPlay() {
        os_log("onPlay", log: log, type: .debug)
    }
    
    func onPause() {
        os_log("onPause", log: log, type: .debug)
    }
    
    func onIntentToFallback() {
        os_log("onIntentToFallback", log: log, type: .debug)
    }
    
    deinit {
        os_log("deinit %d", log: log, type: .debug, _viewId)
    }
}
