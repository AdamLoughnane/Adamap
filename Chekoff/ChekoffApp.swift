import SwiftUI

@main
struct ChekoffApp: App {
    init() {
        NotificationManager.shared.requestPermission()
    }
    
    var body: some Scene {
        WindowGroup {
            HomeScreen()
        }
    }
}
