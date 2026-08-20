import Flutter
import UIKit
import FirebaseCore
import FirebaseMessaging
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Mirrors lib/main.dart's `Firebase.initializeApp()` on the native
    // side, so Firebase is ready before Flutter's own init runs.
    FirebaseApp.configure()

    // Required so FirebaseMessaging can receive the APNs device token
    // forwarded by UIApplicationDelegate below and hand back an FCM
    // token to firebase_messaging on the Dart side.
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }

    // Register immediately. Apple issues the APNs token independently of
    // the alert permission dialog; waiting until Dart requestPermission
    // completes is why getAPNSToken() often stays nil on first launch.
    // (Simulator still will not receive a real APNs token.)
    application.registerForRemoteNotifications()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Flutter 3.41 UIScene: plugins must register here, not in
  // didFinishLaunchingWithOptions. Registering too early leaves the
  // engine running with no attached window (black screen).
  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  // Bridges the raw APNs token to Firebase so `FirebaseMessaging.instance
  // .getToken()` (used in lib/services/notification_service.dart) works.
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    Messaging.messaging().apnsToken = deviceToken
    #if DEBUG
    print("APNs token received (\(deviceToken.count) bytes)")
    #endif
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    #if DEBUG
    print("APNs registration failed: \(error.localizedDescription)")
    #endif
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }

  // Lets a notification banner show while the app is in the foreground on
  // iOS (Android already handles this in NotificationService via
  // flutter_local_notifications). Without this override, iOS silently
  // drops the visual banner for foreground pushes.
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    // `.banner` / `.list` replaced `.alert` in iOS 14. Deployment
    // target is still 13.0, so gate the newer options.
    if #available(iOS 14.0, *) {
      completionHandler([.banner, .list, .sound, .badge])
    } else {
      completionHandler([.alert, .sound, .badge])
    }
  }
}
