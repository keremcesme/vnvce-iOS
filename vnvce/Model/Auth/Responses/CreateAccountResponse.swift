//
//  CreateAccountResponse.swift
//  vnvce
//
//  Created by Kerem Cesme on 19.08.2022.
//

import Foundation

enum CreateAccountResponse: Codable {
    case success(LoginAccountResponse)
    case failure(SMSVerificationError)
}
