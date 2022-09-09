//
//  PhoneNumberAvailability.swift
//  vnvce
//
//  Created by Kerem Cesme on 18.08.2022.
//

import Foundation

enum PhoneNumberAvailability: String, Codable {
    
    case available = "available"
    case alreadyTaken = "alreadyTaken"
    case otpExist = "otpExist"
    
}

extension PhoneNumberAvailability {
    
    func message(_ phoneNumber: String) -> String {
        switch self {
            case .available:
                return "The phone number \"\(phoneNumber)\" is available."
            case .otpExist:
                return "An SMS was sent to this number a short time ago. Please try again later."
            case .alreadyTaken:
                return "This phone number cannot be used."
        }
    }
}
