//
//  AuthRoutes.swift
//  vnvce
//
//  Created by Kerem Cesme on 18.08.2022.
//

import Foundation

enum AuthRoute {
    case create(CARoute)
    case login
    
    var raw: String {
        switch self {
            case .create(_):
                return "auth/create"
            case .login:
                return "auth/login"
        }
    }
}

// MARK: CA => Create Account
enum CARoute {
    case phone(CAPhoneRoute)
    case username(CAUsernameRoute)
    case reserveUsernameAndSendOTP
    case newAccount
    
    var raw: String {
        switch self {
            case .phone:
                return "phone"
            case .username:
                return "username"
            case .reserveUsernameAndSendOTP:
                return "reserve_username_and_send_otp"
            case .newAccount:
                return "new_account"
        }
    }
}

enum CAPhoneRoute {
    case check(String, String)
    case resendOTP
    
    var raw: String {
        switch self {
            case let .check(number, clientID):
                return "check/" + "\(number)/" + "\(clientID)/"
            case .resendOTP:
                return "resend_otp"
        }
    }
}

enum CAUsernameRoute {
    case check(String, String)
    
    var raw: String {
        switch self {
            case let .check(username, clientID):
                return "check/" + "\(username)/" + "\(clientID)/"
        }
    }
}


