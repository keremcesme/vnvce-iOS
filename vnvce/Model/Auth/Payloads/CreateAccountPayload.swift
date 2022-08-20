//
//  CreateAccountPayload.swift
//  vnvce
//
//  Created by Kerem Cesme on 19.08.2022.
//

import Foundation

struct CreateAccountPayload: Encodable {
    let otp: VerifySMSPayload
    let username: String
}
