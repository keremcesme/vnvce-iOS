//
//  ReserveUsernameError.swift
//  vnvce
//
//  Created by Kerem Cesme on 22.08.2022.
//

import Foundation

enum ReserveUsernameError: String, Codable, Error {
    case alreadyTaken = "alreadyTaken"
    case reserved = "reserved"
}
extension ReserveUsernameError {
    func message(_ username: String) -> String {
        switch self {
            case .alreadyTaken:
                return "The username \"\(username)\" is already taken."
            case .reserved:
                return "The username \"\(username)\" is reserved."
        }
    }
}
