import UserNotifications
import Foundation

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("❌ Permission error: \(error)")
            }
            print(granted ? "✅ Notifications permission granted" : "⚠️ Notifications not granted")
        }
    }
    
    /// Schedules your normal half-hour reminders
    func scheduleHalfHourReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let hours = 10...16
        for hour in hours {
            for minute in [0, 30] {
                if hour == 16 && minute == 30 { continue }
                
                var dateComponents = DateComponents()
                dateComponents.hour = hour
                dateComponents.minute = minute
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                
                let content = UNMutableNotificationContent()
                content.title = "Ocularcentro"
                content.body = "Time for an eye exercise 👀"
                content.categoryIdentifier = "TEST_EXERCISE"
                content.sound = .default
                
                let id = "ocularcentro-\(hour)-\(minute)"
                let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request)
            }
        }
    }
    
    /// Schedules ONE debug notification 5s from now
    func scheduleDebugTest() {
        let content = UNMutableNotificationContent()
        content.title = "Ocularcentro (Debug)"
        content.body = "Expand me for a 30s countdown ⏳"
        content.categoryIdentifier = "TEST_EXERCISE"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "ocularcentro-debug-\(UUID().uuidString)",
                                            content: content,
                                            trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Debug notification failed: \(error)")
            } else {
                print("✅ Debug notification scheduled for 5s")
            }
        }
    }
    
    func cancelReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("🗑 Cancelled all pending reminders")
    }
    
    func listPending() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("📋 Pending notifications:")
            for r in requests {
                print(" - \(r.identifier) | category: \(r.content.categoryIdentifier)")
            }
        }
    }
}
