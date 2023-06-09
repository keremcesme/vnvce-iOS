//
//  AppState.swift
//  vnvce
//
//  Created by Kerem Cesme on 10.08.2022.
//

import Foundation
import SwiftUI
import KeychainAccess

class AppState: ObservableObject {
    static let shared = AppState()
    
    @AppStorage("loggedIn") var loggedIn: Bool = false
    @AppStorage("currentUserID") var currentUserID: String = ""
    
    @KeychainStorage("accessToken") var accessToken
    @KeychainStorage("refreshToken") var refreshToken
    
    @Published private(set) public var scenePhase: ScenePhase = .active
    
    init() {
        if loggedIn {
            UIDevice.current.setStatusBar(style: .default, animation: false)
        } else {
            UIDevice.current.setStatusBar(style: .default, animation: false)
        }
        
    }
    
    @Sendable
    public func onChangeScenePhase(_ newPhase: ScenePhase) {
        self.scenePhase = newPhase
    }
}
