//
//  SendSMSOTPResult.swift
//  vnvce
//
//  Created by Kerem Cesme on 19.08.2022.
//

import Foundation

enum SendSMSOTPResult: Codable {
    case success(SMSOTPAttempt)
    case failure(SendSMSOTPError)
}

extension SendSMSOTPResult {
    func message(_ phoneNumber: String) -> String {
        switch self {
            case .success(_):
                return "SMS is Sended"
            case let .failure(error):
                return error.message(phoneNumber)
        }
    }
}
