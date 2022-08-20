//
//  AppDelegate.swift
//  vnvce
//
//  Created by Kerem Cesme on 10.08.2022.
//

import SwiftUI
import AVFoundation
import Firebase
import KeychainAccess

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        
        setup()
        
        return true
    }
    
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
      ) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = SceneDelegate.self
        return sceneConfig
      }
    
    private func setup() {
        setupFirstTimeOpening()
        setupSound()
    }
    
    private func setupSound() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.ambient)
            try audioSession.setActive(true)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func setupFirstTimeOpening() {
        let userDefaults = UserDefaults.standard
        if userDefaults.value(forKey: "appFirstTimeOpen") == nil {
            UIApplication.shared.applicationIconBadgeNumber = 0
            userDefaults.set(true, forKey: "appFirstTimeOpen")
            userDefaults.set(false, forKey: "loggedIn")
            userDefaults.removeObject(forKey: "notificationToken")
            try? Keychain().remove("refreshToken")
            try? Keychain().remove("accessToken")
        }
    }
}

// MARK: Register Remote Notifications -
extension AppDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let userDefaults = UserDefaults.standard
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        userDefaults.set(token, forKey: "notificationToken")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        completionHandler(.newData)
    }
}
