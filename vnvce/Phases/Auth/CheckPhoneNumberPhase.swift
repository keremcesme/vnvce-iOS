//
//  CheckPhoneNumberPhase.swift
//  vnvce
//
//  Created by Kerem Cesme on 19.08.2022.
//

import Foundation

//PhoneNumberAvailability

enum CheckPhoneNumberError: String, Error {
    case otpExist = "An SMS was sent to this number a short time ago. Please try again later."
    case alreadyTaken = "This phone number cannot be used."
    case invalidNumber = "Invalid phone number."
    case taskCancelled = "Task is cancelled."
    case unknown = "An error occured. Try again later."
}

enum CheckPhoneNumberPhase: Equatable {
    case none
    case running
    case success
    case error(CheckPhoneNumberError)
}

