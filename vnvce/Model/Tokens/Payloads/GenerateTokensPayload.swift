//
//  GenerateTokensPayload.swift
//  vnvce
//
//  Created by Kerem Cesme on 22.08.2022.
//

import Foundation

struct GenerateTokensPayload: Encodable {
    let userID: UUID
    let refreshToken: String
    let clientID: UUID
}
