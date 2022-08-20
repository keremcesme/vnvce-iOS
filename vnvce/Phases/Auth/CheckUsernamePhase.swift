//
//  CheckUsernamePhase.swift
//  vnvce
//
//  Created by Kerem Cesme on 19.08.2022.
//

import Foundation

enum CheckUsernameError: String, Error {
    case invalidUsername = "Invalid username."
    case alreadyTaken = "This username cannot be used."
    case reserved = "This username is reserved."
    case taskCancelled = "Task is cancelled."
    case unknown = "An error occured. Try again later."
}

enum CAUsernamePhase: Equatable {
    case none
    
    case running
    case success
    
    case error(CheckUsernameError)
}

