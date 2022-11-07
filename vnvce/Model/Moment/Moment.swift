//
//  Moment'.swift
//  vnvce
//
//  Created by Kerem Cesme on 24.10.2022.
//

import Foundation
import SwiftUI
import PureSwiftUIDesign

struct Moments: Identifiable, Hashable {
    var id = UUID()
    let day: String
    var count: Int
    
    var currentIndex: Int
    var thumbnailImage: CodableImage?
    
    var moments: [Moment] {
        didSet {
            if count != moments.count {
                self.count = moments.count
            }
        }
    }
    
    init(day: String, moments: [Moment]) {
        self.day = day
        self.moments = moments
        self.count = moments.count
        self.currentIndex = 0
    }
}

struct Moment: Decodable, Hashable {
    let id: UUID
    let ownerID:  UUID
    let sensitiveContent: Bool
    let name: String
    let url: String
    let createdAt: TimeInterval
    var date: Int?
    
    var thumbnailImage: CodableImage?
    var downloadedImage: CodableImage?
}

extension Moment {
    var returnURL: URL {
        return URL(string: url)!
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
