//
//  SendSMSOTPResult.swift
//  vnvce
//
//  Created by Kerem Cesme on 19.08.2022.
//

import Foundation



enum SendSMSOTPFailure: String, Codable {
    case alreadyTaken = "alreadyTaken"
    case otpExist = "otpExist"
}

extension SendSMSOTPFailure {
    func message(_ phoneNumber: String) -> String {
        switch self {
            case .otpExist:
                return "OTP code available. Please try again in a short while."
            case .alreadyTaken:
                return "The phone number \"\(phoneNumber)\" is already taken."
        }
    }
}

enum SendSMSOTPResult: Codable {
    case success(SMSOTPAttempt)
    case failure(SendSMSOTPFailure)
}
