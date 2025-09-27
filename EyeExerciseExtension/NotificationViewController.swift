import UIKit
import SwiftUI
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {
    
    private var hostingController: UIHostingController<NotificationView>?

    override func viewDidLoad() {
        super.viewDidLoad()
        print("👀 NotificationViewController loaded")
        
        // Set up SwiftUI view
        let child = UIHostingController(rootView: NotificationView())
        addChild(child)
        child.view.frame = view.bounds
        child.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(child.view)
        child.didMove(toParent: self)
        hostingController = child
    }

    func didReceive(_ notification: UNNotification) {
        // Called when a notification with this extension’s category arrives
        let category = notification.request.content.categoryIdentifier
        print("👀 didReceive called for category: \(category)")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Shrink the extension height to 150 points (adjust to taste)
        self.preferredContentSize = CGSize(width: self.view.bounds.width, height: 150)
    }
}
