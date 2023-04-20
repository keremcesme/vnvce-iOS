
import SwiftUI
import KeychainAccess

class CurrentUserViewModel: ObservableObject {
    private let meAPI = MeAPI()
    private let notificationAPI = NotificationAPI()
    private let keychain = Keychain()
    private let userDefaults = UserDefaults.standard
    
    @Published public var user: User.Private?
    
    init() {
//        Task { await fetchProfile() }
    }

    public func fetchProfile() async {
        do {
            let user = try await meAPI.profile()
            
            guard let user else {
                return
            }
            
            try await registerNotificationToken(user.notificationToken)
            
            await MainActor.run {
                self.user = user
                print("Test Value:")
//                print(self.user!)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func registerNotificationToken(_ token: String?) async throws {
        if let storedToken = userDefaults.value(forKey: UserDefaultsKey.notificationToken) as? String {
            if let token {
                if token != storedToken {
                    try await notificationAPI.registerToken(token: storedToken)
                }
            } else {
                try await notificationAPI.registerToken(token: storedToken)
            }
        }
    }
    
}
