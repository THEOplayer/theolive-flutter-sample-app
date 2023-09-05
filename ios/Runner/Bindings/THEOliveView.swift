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

class THEOliveView: NSObject, FlutterPlatformView, THEOlivePlayerEventListener, THEOliveNativeAPI {
    
    private static var TAG = "FL_IOS_THEOliveView"
    private var _view: UIView
    private let _flutterAPI: THEOliveFlutterAPI
    private let player = THEOliveSDK.THEOlivePlayer()

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
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

    }
    
    func setupEventListeners() {
        
        player.add(eventListener: self)
        
    }
    
    // THEOliveNativeAPI
    func loadChannel(channelID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        print(THEOliveView.TAG + " loadChannel API call")
        self.player.loadChannel(channelID)
        completion(Result.success({}()))
    }
    
    func play() throws {
        self.player.play()
    }
    
    func pause() throws {
        self.player.pause()
    }
    
    // THEOlivePlayerEventListener
    func onChannelLoaded(channelId: String) {
        _flutterAPI.onChannelLoadedEvent(channelID: channelId) {
            print(THEOliveView.TAG + " onChannelLoaded ack received: " + channelId)
        }
    }
    
    func onError(message: String) {
        print(THEOliveView.TAG + " error: " + message)
    }
    
}
