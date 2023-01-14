//
//  vnvceApp.swift
//  vnvce
//
//  Created by Kerem Cesme on 10.08.2022.
//

import SwiftUI
import Firebase
import DeviceCheck
import KeychainAccess
//import CryptoKit
//import VNVCECore

@main
struct vnvceApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject private var appState = AppState()
    @StateObject var notificationCenter = NotificationController()
    
    init() { }
    
    var body: some Scene {
        WindowGroup {
            Group {
                switch appState.loggedIn {
                case true:
                    RootView()
                case false:
                    AuthView()
                }
            }
            .environmentObject(appState)
//            .onReceive(NotificationCenter.default.publisher(for: UIApplication.userDidTakeScreenshotNotification), perform: { _ in
//                print("screen shot")
//            })
            .onReceive(NotificationCenter.default.publisher(for: UIScreen.capturedDidChangeNotification)) { _ in
                //                            isRecordingScreen.toggle()
//                print(isRecordingScreen ? "Started recording screen" : "Stopped recording screen")
            }
            .onAppear {
//                print("Access Token: \(try? Keychain().get(KeychainKey.accessToken))")
//                print("Refresh Token: \(try? Keychain().get(KeychainKey.refreshToken))")
//                print("Logged In: \(appState.loggedIn)")
                
//                let deviceID = UIDevice.current.identifierForVendor?.uuidString ?? ""
                
//                print("Device ID: \(deviceID)")
            }
            .onChange(of: notificationCenter.dumbData) { newValue in
                
            }
//            .onChange(of: scenePhase, perform: appState.onChangeScenePhase)
//                        .onChange(of: scenePhase) { newPhase in
//                            if newPhase == .inactive {
//                                print("Inactive")
//                            } else if newPhase == .active {
//                                print("Active")
//                            } else if newPhase == .background {
//                                print("Background")
//                            }
//                        }
        }
    }
}
