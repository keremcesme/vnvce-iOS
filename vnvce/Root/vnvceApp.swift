//
//  vnvceApp.swift
//  vnvce
//
//  Created by Kerem Cesme on 10.08.2022.
//

import SwiftUI
import Firebase
import DeviceCheck
import CryptoKit

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
                print("Access Token: \(appState.accessToken)")
                print("Refresh Token: \(appState.refreshToken)")
                print("Logged In: \(appState.loggedIn)")
                
                let pkce = PKCEService()
                
                Task {
                    let verifier = await pkce.generateCodeVerifier()
                    let challenge = try await pkce.codeChallenge(fromVerifier: verifier)
                    let deviceID = UIDevice.current.identifierForVendor?.uuidString ?? ""
                    
                    print("Device ID: \(deviceID)")
                    print("Verifier: \(verifier)")
                    print("Challenge: \(challenge)")
                }
                
                
//                do {
//                    let pkce = try PKCEService()
//                    print("Verifier: \(pkce.codeVerifier)")
//                    print("Challenge: \(pkce.codeChallenge)")
//                } catch {
//                    
//                }
                
                
//                let service = DCAppAttestService.shared
//
//
//
//                if service.isSupported {
//                    print("App Attest is supported")
//                    service.generateKey { keyID, error in
//                        guard error == nil else { return }
//                        print("Key: \(keyID)")
//                    }
//                }
//
//                if DCDevice.current.isSupported { // Always test for availability.
//                    DCDevice.current.generateToken { token, error in
//                        guard error == nil else {
//                            return
//                        }
//                        if let data = token {
//                            let xAppleDeviceCheckToken = data.base64EncodedString()
//
////                            print(xAppleDeviceCheckToken)
//                        }
//                    }
//                } else {
//                    print("UNSUPPORTED")
//                }
                
            }
            .onChange(of: notificationCenter.dumbData) { newValue in
                
            }
            .onChange(of: scenePhase, perform: appState.onChangeScenePhase)
            //            .onChange(of: scenePhase) { newPhase in
            //                if newPhase == .inactive {
            //                    print("Inactive")
            //                } else if newPhase == .active {
            //                    print("Active")
            //                } else if newPhase == .background {
            //                    print("Background")
            //                }
            //            }
        }
    }
}
