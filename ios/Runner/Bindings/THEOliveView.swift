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


        let newPlayerView = THEOliveSDK.THEOlivePlayerViewController(player: player)

        newPlayerView.view.translatesAutoresizingMaskIntoConstraints = false
        newPlayerView.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        newPlayerView.view.frame = _view.bounds
        _view.addSubview(newPlayerView.view)

    }
    
    func setupEventListeners() {
        
        player.add(eventListener: self)
        
    }
    
    // THEOliveNativeAPI
    func loadChannel(channelID: String) throws {
        print(THEOliveView.TAG + " loadChannel API call")
        self.player.loadChannel(channelID)
    }
    
    // THEOlivePlayerEventListener
    func onChannelLoaded(channelId: String) {
        _flutterAPI.onChannelLoadedEvent(channelID: channelId) {
            print(THEOliveView.TAG + " onChannelLoaded ack received: " + channelId)
        }
    }
    
}
