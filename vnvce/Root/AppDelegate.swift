
import SwiftUI
import AVFoundation
import Firebase
import KeychainAccess

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    
    private let keychain = Keychain()
    private let userDefaults = UserDefaults.standard
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        let providerFactory = FirebaseAppCheckProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
        
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
        if let accountIsCreated = userDefaults.value(forKey: UserDefaultsKey.accountIsCreated) as? Bool, accountIsCreated {
            userDefaults.set(true, forKey: UserDefaultsKey.loggedIn)
        }
        
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
        if userDefaults.value(forKey: UserDefaultsKey.appFirstTimeOpen) == nil {
            UIApplication.shared.applicationIconBadgeNumber = 0
            userDefaults.set(true, forKey: UserDefaultsKey.appFirstTimeOpen)
            userDefaults.set(false, forKey: UserDefaultsKey.loggedIn)
            userDefaults.set(false, forKey: UserDefaultsKey.accountIsCreated)
            userDefaults.removeObject(forKey: "notificationToken")
            userDefaults.removeObject(forKey: "currentUserID")
            userDefaults.removeObject(forKey: "profilePictureURL")
            try? Keychain().remove("refreshToken")
            try? Keychain().remove("accessToken")
        }
    }
}

// MARK: Register Remote Notifications -
extension AppDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { data in String(format: "%02.2hhx", data) }.joined()
        
        storeToken(token)
    }
    
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        completionHandler(.newData)
    }
    
    private func storeToken(_ token: String) {
        let tokenKey = UserDefaultsKey.notificationToken
        userDefaults.set(token, forKey: tokenKey)
    }
    
}

class FirebaseAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
    func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
        return AppAttestProvider(app: app)
    }
}
