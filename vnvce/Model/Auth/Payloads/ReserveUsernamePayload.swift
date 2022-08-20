//
//  ReserveUsernamePayload.swift
//  vnvce
//
//  Created by Kerem Cesme on 19.08.2022.
//

import Foundation

struct ReserveUsernamePayload: Encodable {
    let username: String
    let clientID: UUID
}
