import UIKit
import Flutter
import UserNotifications

@UIApplicationMain
class AppDelegate: FlutterAppDelegate {
  private let channelName = "dev.napster/alarm"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as? FlutterViewController
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: controller!.binaryMessenger)
    channel.setMethodCallHandler(handle)

    UNUserNotificationCenter.current().delegate = self
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func handle(_ call: FlutterMethodCall, result: FlutterResult) {
    switch call.method {
    case "getTimeZone":
      result(TimeZone.current.identifier)
    case "requestExactAlarm":
      result(true)
    case "schedulePlatformAlarm":
      if let arguments = call.arguments as? [String: Any],
         let milliseconds = arguments["milliseconds"] as? Int64,
         let id = arguments["id"] as? String {
        scheduleNotification(id: id, milliseconds: milliseconds)
      }
      result(nil)
    case "cancelPlatformAlarm":
      if let arguments = call.arguments as? [String: Any],
         let id = arguments["id"] as? String {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
      }
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func scheduleNotification(id: String, milliseconds: Int64) {
    let content = UNMutableNotificationContent()
    content.title = "Napster"
    content.body = "Time to wake up"
    content.sound = UNNotificationSound.default

    let triggerDate = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000.0)
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(triggerDate.timeIntervalSinceNow, 1), repeats: false)
    let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(request)
  }
}
