import UserNotifications
import Foundation

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if !granted {
                print("⚠️ Notifications not granted")
            }
        }
    }
    
    func scheduleHalfHourReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let hours = 10...16 // 10:00 to 16:59
        for hour in hours {
            for minute in [0, 30] {
                if hour == 16 && minute == 30 { continue } // stop at 4pm sharp
                
                var dateComponents = DateComponents()
                dateComponents.hour = hour
                dateComponents.minute = minute
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                
                let content = UNMutableNotificationContent()
                content.title = "Ocularcentro"
                content.body = "Time for an eye exercise 👀"
                
                // 👇 Silent buzz (vibrate only, no sound)
                content.sound = UNNotificationSound(named: UNNotificationSoundName("silent.wav"))
                
                let id = "ocularcentro-\(hour)-\(minute)"
                let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request)
            }
        }
    }
    
    func cancelReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
