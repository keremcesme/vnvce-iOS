//
//  SearchUserResponse.swift
//  vnvce
//
//  Created by Kerem Cesme on 10.09.2022.
//

import Foundation

struct SearchUserResponse: Decodable {
    let users: [User.Public]
    let metadata: PageMetadata
}
