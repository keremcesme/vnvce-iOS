//
//  Post.swift
//  vnvce
//
//  Created by Kerem Cesme on 13.09.2022.
//

import Foundation

struct Post: Decodable {
    let id: UUID
    let description: String?
    let owner: PostOwner
    let media: PostMedia
    let type: PostType
    let archived: Bool
    let createdAt: TimeInterval
    let modifiedAt: TimeInterval
}

struct PostOwner: Decodable {
    let owner: User.Public
    let coOwner: User.Public?
    let approvalStatus: CoPostApprovalStatus?
}

struct PostMedia: Decodable {
    let mediaType: MediaType
    let sensitiveContent: Bool
    let name: String
    let url: String
    let thumbnailURL: String?
    let storageLocation: UUID
}
