import Foundation

class AuxFunctions{
    static func pushNotification(args: [String]) {
      let content = UNMutableNotificationContent()
      content.title = args[0]
      content.body = args[1]

      // Configure the trigger for a 5 seconds delay
      let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

      // Create the request
      let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

      // Schedule the request with the system.
      let center = UNUserNotificationCenter.current()
      center.add(request) { error in
        if let error = error {
          // Handle any errors.
          print("Error scheduling notification: \(error)")
        }
      }
    }
}
