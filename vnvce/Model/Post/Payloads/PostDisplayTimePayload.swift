//
//  PostDisplayTimePayload.swift
//  vnvce
//
//  Created by Kerem Cesme on 7.10.2022.
//

import Foundation

struct PostDisplayTimePayload: Encodable {
    let postID: UUID
    let postDisplayTimeID: UUID?
    let second: Double
    
    init(postID: UUID, postDisplayTimeID: UUID? = nil, second: Double) {
        self.postID = postID
        self.postDisplayTimeID = postDisplayTimeID
        self.second = second
    }
}

