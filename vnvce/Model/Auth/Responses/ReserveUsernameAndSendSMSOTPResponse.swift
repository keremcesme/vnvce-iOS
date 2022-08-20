//
//  ReserveUsernameAndSendSMSOTPResponse.swift
//  vnvce
//
//  Created by Kerem Cesme on 19.08.2022.
//

import Foundation

struct ReserveUsernameAndSendSMSOTPSuccess: Decodable {
    let attemptID: UUID
    let startTime: TimeInterval
    let expiryTime: TimeInterval
}

enum ReserveUsernameAndSendSMSOTPError: Decodable {
    case phone(SendSMSOTPFailure)
    case username(ReserveUsernameFailure)
}

enum ReserveUsernameAndSendSMSOTPStatus: Decodable {
    case success(SMSOTPAttempt)
    case failure(ReserveUsernameAndSendSMSOTPError)
}

struct ReserveUsernameAndSendSMSOTPResponse: Decodable {
    var status: ReserveUsernameAndSendSMSOTPStatus
}
