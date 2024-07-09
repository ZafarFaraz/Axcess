import UIKit
import Flutter
import UserNotifications
import Contacts

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    private var homeManager: HomeManager?
    private var eventManager: EventManager?
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      GeneratedPluginRegistrant.register(with: self)
      
      homeManager = HomeManager()
      eventManager = EventManager()
      
      // Set up method channel
      let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
      let notificationChannel = FlutterMethodChannel(name: "axcessibility_notify", binaryMessenger: controller.binaryMessenger)
      
      notificationChannel.setMethodCallHandler { [weak self] (call, result) in
          if call.method == "pushNotification" {
              if let args = call.arguments as? [String] {
                  AuxFunctions.pushNotification(args: args)
              }
          } else if call.method == "fetchAccessories" { 
              self?.homeManager?.fetchAccessories() {accessories in result(accessories)}
          }
          else if call.method == "toggleAccessory" {
                if let args = call.arguments as? [String: Any],
                   let name = args["name"] as? String,
                   let room = args["room"] as? String {
                    self?.homeManager?.toggleAccessory(name: name, room: room) { success, error in
                        if success {
                            result(nil)
                        } else {
                            result(FlutterError(code: "ERROR", message: "Error toggling accessory", details: error?.localizedDescription))
                        }
                    }
                }
          }
          else if call.method == "requestContactPermission" {
              self?.requestContactPermission(result:result)
          } else if call.method == "loadReminders" {
              self?.eventManager?.loadReminders(result: result)
          } else if call.method == "addReminder" {
                if let args = call.arguments as? [String: Any] {
                    self?.eventManager?.addReminder(args: args, result: result)
                }
            } else if call.method == "updateReminder" {
                if let args = call.arguments as? [String: Any] {
                    self?.eventManager?.updateReminder(args: args, result: result)
                }
            } 
      }
      requestNotificationPermission()
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func requestNotificationPermission() {
    let center = UNUserNotificationCenter.current()
    center.delegate = self

    center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
      if let error = error {
        print("Error in getting user permission")
      } else if granted {
        print("Notification permission granted")
      } else {
        print("Notification permission denied")
      }
    }

    // Register for remote notifications
    UIApplication.shared.registerForRemoteNotifications()
  }

  private func requestReminderAccess(result: @escaping FlutterResult) {
      self.eventManager?.eventStore.requestFullAccessToReminders(){ (granted, error) in
            if granted {
                self.eventManager?.loadReminders(result: result)
            } else {
                result(FlutterError(code: "PERMISSION_DENIED", message: "Access to reminders denied", details: nil))
            }
        }
    }
    
    private func requestContactPermission(result: @escaping FlutterResult) {
                let store = CNContactStore()
                store.requestAccess(for: .contacts) { granted, error in
                    if let error = error {
                        result(FlutterError(code: "ERROR", message: "Error requesting contact permission", details: error.localizedDescription))
                    } else {
                        result(granted)
         }
       }
    }
    
  
  // Handle notifications when app is in foreground
  override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([.banner, .badge, .sound])
  }
}

