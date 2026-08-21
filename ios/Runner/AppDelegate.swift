import Flutter
import GoogleMaps
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Phase 11: real Google Maps SDK key. Hardcoded here (unlike Android's
    // local.properties injection) only because iOS is still unbuilt/
    // unverified on this Windows dev machine (no Xcode) -- see
    // KNOWN_LIMITATIONS.md. Replace this placeholder with a real key, or
    // wire it through an xcconfig, before ever building for iOS.
    GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY_HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
