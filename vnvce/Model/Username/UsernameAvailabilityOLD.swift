//
//  UsernameAvailabilityOLD.swift
//  vnvce
//
//  Created by Kerem Cesme on 22.08.2022.
//

import Foundation

enum UsernameAvailabilityOLD: String, Codable {
    case available = "available"
    case alreadyTaken = "alreadyTaken"
    case reserved = "reserved"
}

extension UsernameAvailabilityOLD {
    
    func message(_ username: String) -> String {
        switch self {
            case .available:
                return "The username \"\(username)\" is available."
            case .reserved:
                return "The username \"\(username)\" is reserved."
            case .alreadyTaken:
                return "The username \"\(username)\" is already taken."
        }
    }
}