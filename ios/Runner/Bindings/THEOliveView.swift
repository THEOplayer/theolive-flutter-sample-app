//
//  THEOliveNativeView.swift
//  flutter_theolive
//
//  Created by Daniel on 16/07/2023.
//

import Foundation
import Flutter
import UIKit
import THEOliveSDK

class THEOliveView: NSObject, FlutterPlatformView, THEOlivePlayerEventListener {
    
    private static var TAG = "FL_IOS_THEOliveView"
    private var _view: UIView
    private var _channel: FlutterMethodChannel

    private let player = THEOliveSDK.THEOlivePlayer()

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        _view = UIView()
        _view.frame = frame
        _channel = FlutterMethodChannel(name: "THEOliveView/\(viewId)", binaryMessenger: messenger!)
                
        super.init()
        
        // iOS views can be created here
        createNativeView(view: _view)
        setupEventListeners()
                
        _channel.setMethodCallHandler({ (call: FlutterMethodCall, result: FlutterResult) -> Void in
          // receive calls from Dart
          switch call.method {
              case "loadChannel":
               guard let args = call.arguments as? [String: Any],
                 let channelId = args["channelId"] as? String else {
                 result(FlutterError(code: "ERROR_1", message: "Missing channelId!", details: nil))
                 return
               }
                self.player.loadChannel(channelId)
                print(THEOliveView.TAG + " SWIFT loadChannel success")
                result(nil)
            case "play":
                print("SWIFT play!, not implemented")
          default:
              result(FlutterMethodNotImplemented)
          }
        })
         
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
    
    func loadChannel(channelID: String) throws {
        print(THEOliveView.TAG + " SWIFT loadChannel API call")
        self.player.loadChannel(channelID)
    }
    
    func onChannelLoaded(channelId: String) {
        // method channel invokeMethod with callback
        
        self._channel.invokeMethod("onChannelLoaded", arguments: channelId) { (result) in
            print(THEOliveView.TAG + "SWIFT onChannelLoaded ack received: " + String(describing: result))
        }
        
    }
    
}
