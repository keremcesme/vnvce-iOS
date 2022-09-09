//
//  VerifySMSPayload.swift
//  vnvce
//
//  Created by Kerem Cesme on 22.08.2022.
//

import Foundation

struct VerifySMSPayload: Encodable {
    let phoneNumber: String
    let otpCode: String
    let clientID: UUID
    let attemptID: UUID
}
