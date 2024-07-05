import UIKit
import Flutter
import UserNotifications
import Contacts
import EventKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    private var homeManager: HomeManager?
    private let eventStore = EKEventStore()
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      GeneratedPluginRegistrant.register(with: self)
      
      homeManager = HomeManager()
      
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
              self?.loadReminders(result: result)
          } else if call.method == "addReminder" {
                if let args = call.arguments as? [String: Any] {
                    self?.addReminder(args: args, result: result)
                }
            } else if call.method == "updateReminder" {
                if let args = call.arguments as? [String: Any] {
                    self?.updateReminder(args: args, result: result)
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
        eventStore.requestFullAccessToReminders(){ (granted, error) in
            if granted {
                self.loadReminders(result: result)
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

    private func loadReminders(result: @escaping FlutterResult) {
    eventStore.requestFullAccessToReminders(){ (granted, error) in
      if granted {
        let predicate = self.eventStore.predicateForReminders(in: nil)
        self.eventStore.fetchReminders(matching: predicate) { reminders in
          var reminderList = [[String: Any]]()
          for reminder in reminders ?? [] {
            let title = reminder.title ?? ""
            let notes = reminder.notes ?? ""
            let completed = reminder.isCompleted
            reminderList.append([
              "title": title,
              "notes": notes,
              "completed": completed
            ])
          }
          result(reminderList)
        }
      } else {
        result(FlutterError(code: "PERMISSION_DENIED", message: "Access to reminders denied", details: nil))
      }
    }
  }

  private func addReminder(args: [String: Any], result: @escaping FlutterResult) {
        let title = args["title"] as? String ?? ""
        let notes = args["notes"] as? String ?? ""

        let reminder = EKReminder(eventStore: eventStore)
        reminder.title = title
        reminder.notes = notes
        reminder.calendar = eventStore.defaultCalendarForNewReminders()

        do {
            try eventStore.save(reminder, commit: true)
            result("Reminder added successfully")
        } catch {
            result(FlutterError(code: "ADD_REMINDER_ERROR", message: "Failed to add reminder", details: error.localizedDescription))
        }
    }

    private func updateReminder(args: [String: Any], result: @escaping FlutterResult) {
        let calendarItemIdentifier = args["calendarItemIdentifier"] as? String ?? ""
        let title = args["title"] as? String ?? ""
        let notes = args["notes"] as? String ?? ""
        let completed = args["completed"] as? Bool ?? false

        let reminder = eventStore.calendarItem(withIdentifier: calendarItemIdentifier) as? EKReminder

        if let reminder = reminder {
            reminder.title = title
            reminder.notes = notes
            reminder.isCompleted = completed

            do {
                try eventStore.save(reminder, commit: true)
                result("Reminder updated successfully")
            } catch {
                result(FlutterError(code: "UPDATE_REMINDER_ERROR", message: "Failed to update reminder", details: error.localizedDescription))
            }
        } else {
            result(FlutterError(code: "REMINDER_NOT_FOUND", message: "Reminder not found", details: nil))
        }
    }
    
  
  // Handle notifications when app is in foreground
  override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([.banner, .badge, .sound])
  }
}

