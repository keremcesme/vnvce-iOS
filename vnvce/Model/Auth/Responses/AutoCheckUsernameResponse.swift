//
//  AutoCheckUsernameResponse.swift
//  vnvce
//
//  Created by Kerem Cesme on 19.08.2022.
//

import Foundation

struct AutoCheckUsernameResponse: Decodable {
    let status: UsernameAvailability
}
