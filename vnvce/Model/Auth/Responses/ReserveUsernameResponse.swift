//
//  ReserveUsernameResponse.swift
//  vnvce
//
//  Created by Kerem Cesme on 19.08.2022.
//

import Foundation

enum ReserveUsernameStatus: Decodable {
    case success
    case failure(UsernameAvailabilityOLD)
}

struct ReserveUsernameResponse: Decodable {
    var status: ReserveUsernameStatus
}
