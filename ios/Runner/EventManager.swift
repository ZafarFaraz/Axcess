import EventKit
import Foundation

class EventManager : NSObject {
    
    let eventStore = EKEventStore()
    
    override init() {
        super.init()
    }
    
    func loadReminders(result: @escaping FlutterResult) {
    eventStore.requestFullAccessToReminders(){  (granted, error) in
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

  func addReminder(args: [String: Any], result: @escaping FlutterResult) {
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

    func updateReminder(args: [String: Any], result: @escaping FlutterResult) {
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
}
