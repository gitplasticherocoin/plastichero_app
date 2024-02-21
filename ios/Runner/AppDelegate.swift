import UIKit
import Flutter
import GoogleMaps
import flutter_downloader

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
//        GMSServices.provideAPIKey("AIzaSyBrGspTTUK6kk0tbGq0srrUd7n_GaA23U4")
        GeneratedPluginRegistrant.register(with: self)
        FlutterDownloaderPlugin.setPluginRegistrantCallback( { registry in
            if(!registry.hasPlugin("FlutterDownloaderPlugin")) {
                FlutterDownloaderPlugin.register(with: registry.registrar(forPlugin: "FlutterDownloaderPlugin")!)
            }
            
        })
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
        }
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
