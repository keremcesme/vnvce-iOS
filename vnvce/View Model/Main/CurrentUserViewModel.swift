//
//  CurrentUserViewModel.swift
//  vnvce
//
//  Created by Kerem Cesme on 7.09.2022.
//

import Foundation
import SwiftUI

class CurrentUserViewModel: ObservableObject {
    @AppStorage("profilePictureURL") var profilePictureURL: String = ""
    
    private let meAPI = MeAPI.shared
    
    @Published private(set) public var user: User? = nil
    
    public func fetchProfile() async {
        await fetchProfileTask()
    }
}

extension CurrentUserViewModel {
    
    private func fetchProfileTask() async {
        if Task.isCancelled { return }
        do {
            let user = try await meAPI.fetchProfile()
            if Task.isCancelled { return }
            await MainActor.run {
                self.user = user
                setProfilePictureURL()
            }
        } catch {
            if Task.isCancelled { return }
            print(error.localizedDescription)
            return
        }
    }
    
    private func setProfilePictureURL() {
        guard let user = user else {
            UserDefaults.standard.removeObject(forKey: "profilePictureURL")
            return
        }
        
        guard let profilePicture = user.profilePicture else {
            UserDefaults.standard.removeObject(forKey: "profilePictureURL")
            return
        }
        
        if self.profilePictureURL != profilePicture.url {
            self.profilePictureURL = profilePicture.url
        }
    }
}
