//
//  User.swift
//  vnvce
//
//  Created by Kerem Cesme on 19.08.2022.
//

import Foundation
import VNVCECore

struct User: Codable, Equatable, Hashable {
    
    let id: UUID
    let username: String
    let phoneNumber: String
    let displayName: String?
    let biography: String?
    let profilePicture: ProfilePicture?
    
    struct PublicOLD: Codable, Equatable, Hashable {
        let id: UUID
        let username: String
        let displayName: String?
        let biography: String?
        let profilePicture: ProfilePicture?
    }
    
    typealias Public = VNVCECore.User.V1.Public
    typealias Private = VNVCECore.User.V1.Private
}




