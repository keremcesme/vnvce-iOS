//
//  Moment'.swift
//  vnvce
//
//  Created by Kerem Cesme on 24.10.2022.
//

import Foundation
import SwiftUI
import PureSwiftUIDesign
import VNVCECore


struct Moment: Decodable, Hashable {
    var thumbnailImage: CodableImage?
    var downloadedImage: CodableImage?
    
    typealias Public = VNVCECore.Moment.V1.Public
    typealias Private = VNVCECore.Moment.V1.Private
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
