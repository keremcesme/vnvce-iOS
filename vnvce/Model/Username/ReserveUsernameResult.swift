//
//  ReserveUsernameResult.swift
//  vnvce
//
//  Created by Kerem Cesme on 22.08.2022.
//

import Foundation

enum ReserveUsernameResult: Encodable {
    case success
    case failure(ReserveUsernameError)
}

extension ReserveUsernameResult {
    func message(_ username: String) -> String {
        switch self {
            case .success:
                return "Reserve success."
            case let .failure(error):
                return error.message(username)
        }
    }
}
