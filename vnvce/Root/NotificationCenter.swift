
import UIKit
import UserNotifications
import KeychainAccess


class NotificationController: NSObject, ObservableObject {
    private let application = UIApplication.shared
    private let center = UNUserNotificationCenter.current()
    private let keycahin = Keychain()
    
    @Published private(set) public var dumbData: UNNotificationResponse?
    
    override init() {
        super.init()
        center.delegate = self
        application.registerForRemoteNotifications()
    }
    
    public func requestAuthorization() async {
        do {
            try await center.requestAuthorization(options: [.alert, .sound, .badge])
            
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension NotificationController: UNUserNotificationCenterDelegate  {
    
    // Receive
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("RECEIVE")
        let userInfo = notification.request.content.userInfo
        guard let aps = userInfo[AnyHashable("aps")] as? NSDictionary else { return }
        print(userInfo)
        
        completionHandler([.banner, .sound, .badge])
    }
    
    // Press
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("PRESSED")
        dumbData = response
        print(response.notification.request.content.userInfo[AnyHashable("aps")] as? NSDictionary ?? "")
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) { }
}
