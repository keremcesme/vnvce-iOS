//
//  CreateAccountResponse.swift
//  vnvce
//
//  Created by Kerem Cesme on 19.08.2022.
//

import Foundation

struct CreateAccountSuccess: Decodable, Equatable {
    let user: User
    let tokens: Tokens
}

enum CreateAccountStatus: Decodable {
    case success(CreateAccountSuccess)
    case failure(SMSVerificationResult)
}

struct CreateAccountResponse: Decodable {
    let status: CreateAccountStatus
}
