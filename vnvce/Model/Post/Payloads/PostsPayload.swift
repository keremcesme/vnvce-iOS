//
//  PostsPayload.swift
//  vnvce
//
//  Created by Kerem Cesme on 28.09.2022.
//

import Foundation

enum PostsPayload: Encodable {
    case me(archived: Bool)
    case user(userID: UUID)
}
