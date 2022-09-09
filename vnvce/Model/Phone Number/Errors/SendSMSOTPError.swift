//
//  SendSMSOTPError.swift
//  vnvce
//
//  Created by Kerem Cesme on 22.08.2022.
//

import Foundation

enum SendSMSOTPError: String, Codable, Error {
    case alreadyTaken = "alreadyTaken"
    case otpExist = "otpExist"
}

extension SendSMSOTPError {
    func message(_ phoneNumber: String) -> String {
        switch self {
            case .otpExist:
                return "OTP code available. Please try again in a short while."
            case .alreadyTaken:
                return "The phone number \"\(phoneNumber)\" is already taken."
        }
    }
}
