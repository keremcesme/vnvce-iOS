//
//  LoginAccountResponse.swift
//  vnvce
//
//  Created by Kerem Cesme on 22.08.2022.
//

import Foundation

struct LoginAccountResponse: Codable, Equatable {
    let user: User
    let tokens: Tokens
}
