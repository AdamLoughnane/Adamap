import SwiftUI
import UserNotifications

@main
struct ChekoffApp: App {
    init() {
        // 👇 make sure notifications show even when unlocked or in foreground
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }
    
    var body: some Scene {
        WindowGroup {
            HomeScreen()
                .onAppear {
                    NotificationManager.shared.requestPermission()
                    NotificationManager.shared.scheduleHalfHourReminders()
                }
        }
    }
}
