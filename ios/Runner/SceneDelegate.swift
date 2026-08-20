import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  // Flutter 3.41 UIScene no longer delivers applicationDidBecomeActive
  // to AppDelegate, which is where firebase_messaging re-registers for
  // APNs. Re-register here so a physical iPhone still gets a token.
  override func sceneDidBecomeActive(_ scene: UIScene) {
    super.sceneDidBecomeActive(scene)
    UIApplication.shared.registerForRemoteNotifications()
  }
}
