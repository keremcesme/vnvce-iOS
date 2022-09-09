//
//  vnvceApp.swift
//  vnvce
//
//  Created by Kerem Cesme on 10.08.2022.
//

import SwiftUI
import Firebase

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
                        HomeView()
                    case false:
                        AuthView()
                }
            }
            .environmentObject(appState)
            .onAppear {
                print("Access Token: \(appState.accessToken)")
                print("Refresh Token: \(appState.refreshToken)")
                print("Logged In: \(appState.loggedIn)")
            }
            .onChange(of: notificationCenter.dumbData) { newValue in
                
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .inactive {
                    print("Inactive")
                } else if newPhase == .active {
                    print("Active")
                } else if newPhase == .background {
                    print("Background")
                }
            }
        }
    }
}


