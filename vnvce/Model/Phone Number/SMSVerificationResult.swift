//
//  SMSVerificationResult.swift
//  vnvce
//
//  Created by Kerem Cesme on 22.08.2022.
//

import Foundation

enum SMSVerificationResult: String, Codable {
    case verified = "verified"
    case expired = "expired"
    case failure = "failure"
}
