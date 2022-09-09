//
//  ReserveUsernameAndSendSMSOTPResponse.swift
//  vnvce
//
//  Created by Kerem Cesme on 19.08.2022.
//

import Foundation

enum ReserveUsernameAndSendSMSOTPError: Codable {
    case phone(SendSMSOTPError)
    case username(ReserveUsernameError)
}

enum ReserveUsernameAndSendSMSOTPResponse: Decodable {
    case success(SMSOTPAttempt)
    case failure(ReserveUsernameAndSendSMSOTPError)
}
