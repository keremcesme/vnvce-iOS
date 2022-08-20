//
//  CreateAccountPhase.swift
//  vnvce
//
//  Created by Kerem Cesme on 20.08.2022.
//

import Foundation

enum CreateAccountError: String, Error {
    case otpExpired = "The SMS verification has expired. Please try again."
    case otpNotVerified = "SMS could not be verified."
    case taskCancelled = "Task is cancelled."
    case unknown = "An error occured. Try again later."
}

enum CreateAccountPhase: Equatable {
    case none
    case running
    case success(CreateAccountSuccess)
    case error(CreateAccountError)
}
