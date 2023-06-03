
import SwiftUI

@main
struct vnvceApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject private var appState = AppState()
    @StateObject private var notificationCenter = NotificationController()
    
    var body: some Scene {
        WindowGroup(content: GroupView)
    }
    
    @ViewBuilder
    private func GroupView() -> some View {
        Group(content: RootView)
            .environmentObject(appState)
            .environmentObject(notificationCenter)
            .onChange(of: scenePhase, perform: appState.onChangeScenePhase)
    }
    
    @ViewBuilder
    private func RootView() -> some View {
        switch appState.loggedIn {
        case true:
            HomeView()
//                .colorScheme(.dark)
        case false:
            AuthView()
        }
    }
}



//    .onReceive(NotificationCenter.default.publisher(for: UIScreen.capturedDidChangeNotification)) { _ in
//
//    }
//
//    .onChange(of: notificationCenter.dumbData) { newValue in
//
//    }



//            .onReceive(NotificationCenter.default.publisher(for: UIApplication.userDidTakeScreenshotNotification), perform: { _ in
//                print("screen shot")
//            })
//                            isRecordingScreen.toggle()
//                print(isRecordingScreen ? "Started recording screen" : "Stopped recording screen")
//            .onAppear {
//                print("Access Token: \(try? Keychain().get(KeychainKey.accessToken))")
//                print("Refresh Token: \(try? Keychain().get(KeychainKey.refreshToken))")
//                print("Logged In: \(appState.loggedIn)")

//                let deviceID = UIDevice.current.identifierForVendor?.uuidString ?? ""

//                print("Device ID: \(deviceID)")
//            }
            
//                        .onChange(of: scenePhase) { newPhase in
//                            if newPhase == .inactive {
//                                print("Inactive")
//                            } else if newPhase == .active {
//                                print("Active")
//                            } else if newPhase == .background {
//                                print("Background")
//                            }
//                        }
