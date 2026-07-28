import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    // Force dark appearance app-wide so Apple Maps (MKMapView) renders its
    // native dark tiles, matching the app's dark design (no dark-mode API
    // is exposed by the apple_maps_flutter plugin itself).
    self.window?.overrideUserInterfaceStyle = .dark
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Reset the app icon badge whenever the app comes to the foreground, since
  // the badge count comes from the APNs push payload (aps.badge) and nothing
  // clears it automatically once the user has actually opened the app.
  override func applicationDidBecomeActive(_ application: UIApplication) {
    if #available(iOS 16.0, *) {
      UNUserNotificationCenter.current().setBadgeCount(0, withCompletionHandler: nil)
    } else {
      application.applicationIconBadgeNumber = 0
    }
    super.applicationDidBecomeActive(application)
  }
}


