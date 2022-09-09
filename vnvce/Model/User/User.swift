//
//  User.swift
//  vnvce
//
//  Created by Kerem Cesme on 19.08.2022.
//

import Foundation

struct User: Codable, Equatable {
    
    let id: UUID
    let username: String
    let phoneNumber: String
    let displayName: String?
    let biography: String?
    let profilePicture: ProfilePicture?
    
    struct Public: Codable {
        let id: UUID
        let username: String
        let displayName: String?
        let biography: String?
        let profilePicture: ProfilePicture?
    }
}
