//
//  Post.swift
//  vnvce
//
//  Created by Kerem Cesme on 13.09.2022.
//

import Foundation

struct Post: Decodable, Hashable {
    let id: UUID
    let description: String?
    let owner: Owner
    let media: Media
    let type: PostType
    let archived: Bool
    let createdAt: TimeInterval
    let modifiedAt: TimeInterval
    
    struct Owner: Decodable, Hashable {
        let owner: User.Public
        let coOwner: User.Public?
        let approvalStatus: CoPostApprovalStatus?
    }
    
    struct Media: Decodable, Hashable {
        let mediaType: MediaType
        let sensitiveContent: Bool
        let name: String
        let url: String
        let thumbnailURL: String?
        let storageLocation: UUID
    }
}

extension Post.Media {
    var returnURL: URL {
        switch mediaType {
        case .image:
            return URL(string: url)!
        case .movie:
            return URL(string: thumbnailURL!)!
        }
    }
}

//struct PostOwner: Decodable, Hashable {
//    let owner: User.Public
//    let coOwner: User.Public?
//    let approvalStatus: CoPostApprovalStatus?
//}
//
//struct PostMedia: Decodable, Hashable {
//    let mediaType: MediaType
//    let sensitiveContent: Bool
//    let name: String
//    let url: String
//    let thumbnailURL: String?
//    let storageLocation: UUID
//}


