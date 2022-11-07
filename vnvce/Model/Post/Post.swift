//
//  Post.swift
//  vnvce
//
//  Created by Kerem Cesme on 13.09.2022.
//

import Foundation
import SwiftUI
import PureSwiftUIDesign

struct Post: Decodable, Hashable {
    let id: UUID
    let description: String?
    let owner: Owner
    let media: Media
    let type: PostType
    
    var totalWatchTime: Int
    var displayTime: DisplayTime?
    
    let archived: Bool
    let createdAt: TimeInterval
    let modifiedAt: TimeInterval
    var previewImage: CodableImage?
    
    struct Owner: Decodable, Hashable {
        let owner: User.Public
        let coOwner: User.Public?
        let approvalStatus: CoPostApprovalStatus?
    }
    
    struct Media: Decodable, Hashable {
        let mediaType: MediaType
        let sensitiveContent: Bool
        let name: String
        let ratio: Float
        let url: String
        let thumbnailURL: String?
        let storageLocation: UUID
    }
    
    struct DisplayTime: Decodable, Hashable {
        let id: UUID
        let second: Double
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

extension Post.Media {
    var returnSize: CGSize {
        let screenWidth = UIScreen.main.bounds.width
        
        return CGSize(screenWidth, screenWidth * ratio.asCGFloat)
    }
}

