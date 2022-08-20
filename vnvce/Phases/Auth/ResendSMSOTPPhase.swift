//
//  ResendSMSOTPPhase.swift
//  vnvce
//
//  Created by Kerem Cesme on 20.08.2022.
//

import Foundation

enum ResendSMSOTPError: String, Error {
    case taskCancelled = "Task is cancelled."
    case unknown = "An error occured. Try again later."
}

enum ResendSMSOTPPhase: Equatable {
    case none
    case running
    case success
    case error(ResendSMSOTPError)
}
