//
//  MomentsPayload.swift
//  vnvce
//
//  Created by Kerem Cesme on 24.10.2022.
//

import Foundation

enum MomentsPayload: Encodable {
    case me
    case user(userID: UUID)
}
