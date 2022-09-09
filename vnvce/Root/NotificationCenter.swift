//
//  NotificationCenter.swift
//  vnvce
//
//  Created by Kerem Cesme on 10.08.2022.
//

import UIKit

class NotificationController: NSObject, ObservableObject {
    @Published var dumbData: UNNotificationResponse?
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
}

extension NotificationController: UNUserNotificationCenterDelegate  {
    // Receive
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        guard let aps = userInfo[AnyHashable("aps")] as? NSDictionary else { return }
        print(aps)
        
        completionHandler([.banner, .sound, .badge])
    }
    
    // Press
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        dumbData = response
        print(response.notification.request.content.userInfo[AnyHashable("aps")] as? NSDictionary ?? "")
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) { }
}
