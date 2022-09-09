//
//  AuthPhases.swift
//  vnvce
//
//  Created by Kerem Cesme on 22.08.2022.
//

import Foundation

enum CheckPhoneNumberPhase: Equatable {
    case none
    case running
    case success
    case error(CheckPhoneNumberError)
}

enum CheckPhoneNumberError: String, Error {
    case otpExist = "An SMS was sent to this number a short time ago. Please try again later."
    case alreadyTaken = "This phone number cannot be used."
    case invalidNumber = "Invalid phone number."
    
    case taskCancelled = "Task is cancelled."
    case unknown = "An error occured. Try again later."
}

enum CAUsernamePhase: Equatable {
    case none
    
    case running
    case success
    
    case error(CheckUsernameError)
}

enum CheckUsernameError: String, Error {
    case invalidUsername = "Invalid username."
    case alreadyTaken = "This username cannot be used."
    case reserved = "This username is reserved."
    case taskCancelled = "Task is cancelled."
    case unknown = "An error occured. Try again later."
}

enum ReserveUsernameAndSendOTPPhase: Equatable {
    case none
    case running
    case success
    case error(ReserveUsernameAndSendOTPError)
}

enum ReserveUsernameAndSendOTPError: String, Error {
    case usernameAlreadyTaken = "This username cannot be used."
    case usernameIsReserved = "This username is reserved."
    
    case numberAlreadyTaken = "This phone number cannot be used."
    case otpExist = "An SMS was sent to this number a short time ago. Please try again later."
    
    case taskCancelled = "Task is cancelled."
    case unknown = "An error occured. Try again later."
}

enum ResendSMSOTPPhase: Equatable {
    case none
    case running
    case success
    case error(ResendSMSOTPError)
}

enum ResendSMSOTPError: String, Error {
    case taskCancelled = "Task is cancelled."
    case unknown = "An error occured. Try again later."
}

enum CreateAccountPhase: Equatable {
    case none
    case running
    case success(LoginAccountResponse)
    case error(CreateAccountError)
}

enum CreateAccountError: String, Error, Equatable {
    case otpExpired = "The SMS verification has expired. Please try again."
    case otpNotVerified = "SMS could not be verified."
    case taskCancelled = "Task is cancelled."
    case unknown = "An error occured. Try again later."
}

enum CAOptionalPhase: Equatable {
    case none
    case running
    case success
    case error(CAOptionalError)
}

enum CAOptionalError: String, Error, Equatable {
    case taskCancelled = "Task is cancelled."
    case unknown = "An error occured. Try again later."
}
