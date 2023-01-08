//
//  SceneDelegate.swift
//  vnvce
//
//  Created by Kerem Cesme on 20.08.2022.
//

import Foundation
import SwiftUI
import UIKit
import Cache

class SceneDelegate: NSObject, UIWindowSceneDelegate, ObservableObject {
    
    @Published var accountIsCreated: Bool = false
    
    private let diskConfig = DiskConfig(name: "Moment",
                                        maxSize: 1_073_741_824,
                                        protectionType: .complete)
    
    private let memoryConfig = MemoryConfig(expiry: .seconds(86400))
    private let transformer = TransformerFactory.forData()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions
    ) {
        // ...
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // ...
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // ...
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // ...
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
        let userDefaults = UserDefaults.standard
        if accountIsCreated {
            userDefaults.set(true, forKey: "loggedIn")
        }
        
        removeMomentsCache()
        
        print("~ SCENE UPDATE ~ Disconected or Terminated App")
        
    }
    
    private func removeMomentsCache() {
        do {
            let storage: Storage<String, Data> = try Storage(
                diskConfig: diskConfig,
                memoryConfig: memoryConfig,
                transformer: transformer
            )
            
            try storage.removeExpiredObjects()
            
        } catch { return }
    }
    
}
