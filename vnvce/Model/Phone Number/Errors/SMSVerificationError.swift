//
//  SMSVerificationError.swift
//  vnvce
//
//  Created by Kerem Cesme on 22.08.2022.
//

import Foundation

enum SMSVerificationError: String, Codable, Error {
    case expired = "expired"
    case failure = "failure"
}
