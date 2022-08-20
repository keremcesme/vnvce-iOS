//
//  SendSMSOTPResponse.swift
//  vnvce
//
//  Created by Kerem Cesme on 19.08.2022.
//

import Foundation

struct SendSMSOtpSuccess: Decodable {
    let attemptID: UUID
    let startTime: TimeInterval
    let expiryTime: TimeInterval
}

enum SendSMSOTPStatus: Decodable {
    case sended(SendSMSOtpSuccess)
    case failure(PhoneNumberAvailability)
}

struct SendSMSOTPResponse: Decodable {
    var status: SendSMSOTPStatus
}
