//
//  VerifySMS.swift
//  vnvce
//
//  Created by Kerem Cesme on 19.08.2022.
//

import Foundation

struct VerifySMSPayload: Codable {
    let phoneNumber: String
    let otpCode: String
    let clientID: UUID
    let attemptID: UUID
}

enum SMSVerificationResult: String, Codable {
//    case verified = "verified"
    case expired = "expired"
    case failure = "failure"
}
