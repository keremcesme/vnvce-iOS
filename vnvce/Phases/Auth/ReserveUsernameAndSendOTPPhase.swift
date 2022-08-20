//
//  ReserveUsernameAndSendOTPPhase.swift
//  vnvce
//
//  Created by Kerem Cesme on 19.08.2022.
//

import Foundation

enum ReserveUsernameAndSendOTPError: String, Error {
    case usernameAlreadyTaken = "This username cannot be used."
    case usernameIsReserved = "This username is reserved."
    
    case numberAlreadyTaken = "This phone number cannot be used."
    case otpExist = "An SMS was sent to this number a short time ago. Please try again later."
    
    case taskCancelled = "Task is cancelled."
    case unknown = "An error occured. Try again later."
}

enum ReserveUsernameAndSendOTPPhase: Equatable {
    case none
    case running
    case success
    case error(ReserveUsernameAndSendOTPError)
}
