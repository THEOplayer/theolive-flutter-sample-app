import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
   
    weak var registrar = self.registrar(forPlugin: "live.theo.theoliveview")

    let factory = THEOliveViewFactory(messenger: registrar!.messenger())
    registrar?.register(factory, withId: "theoliveview")
      
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
