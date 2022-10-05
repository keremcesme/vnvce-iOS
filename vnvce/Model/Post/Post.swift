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
    let totalSeconds: Int
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

struct CodableImage: Codable, Hashable {
    let image: UIImage?

    init(image: UIImage) {
        self.image = image
    }

    enum CodingKeys: CodingKey {
        case data
        case scale
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let scale = try container.decode(CGFloat.self, forKey: .scale)
        let data = try container.decode(Data.self, forKey: .data)
        self.image = UIImage(data: data, scale: scale)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let image = self.image {
            try container.encode(image.pngData(), forKey: .data)
            try container.encode(image.scale, forKey: .scale)
        }
    }
}
