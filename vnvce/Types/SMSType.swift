//
//  SMSType.swift
//  vnvce
//
//  Created by Kerem Cesme on 19.08.2022.
//

import Foundation

enum SMSType: String, Codable {
    case login = "login"
    case createAccount = "createAccount"
}

extension SMSType {
    
    func message(code: String) -> String {
        
        let type: String = {
            switch self {
                case .login:
                    return "logging into"
                case .createAccount:
                    return "creating"
            }
        }()
        
        let message = "Verification code for \(type) vnvce account: \(code).\nIf you did not request this, disregard this message."
        
        return message
    }
}
