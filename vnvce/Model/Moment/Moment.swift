
import Foundation
import SwiftUI
import VNVCECore

struct PublicMoment: Equatable, Hashable {
    var detail: Moment.Public
    var imageDownloadState: ImageDownloadState = .nothing
}

extension VNVCECore.Moment.V1.Public {
    var convertToPublicMoment: PublicMoment {
        return .init(detail: self)
    }
    
    var convertToMomentVM: MomentViewModel {
        return .init(moment: self)
    }
}

extension Array where Element == VNVCECore.Moment.V1.Public {
    var convertToPublicMoment: [PublicMoment] {
        return self.map { value in
            value.convertToPublicMoment
        }
    }
    
    var convertToMomentVM: [MomentViewModel] {
        return self.map { moment in
            moment.convertToMomentVM
        }
    }
}

struct Moment {
    typealias Public = VNVCECore.Moment.V1.Public
    typealias Private = VNVCECore.Moment.V1.Private
}

//struct CodableImage: Codable, Hashable {
//    let image: UIImage?
//
//    init(image: UIImage) {
//        self.image = image
//    }
//
//    enum CodingKeys: CodingKey {
//        case data
//        case scale
//    }
//
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        let scale = try container.decode(CGFloat.self, forKey: .scale)
//        let data = try container.decode(Data.self, forKey: .data)
//        self.image = UIImage(data: data, scale: scale)
//    }
//
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        if let image = self.image {
//            try container.encode(image.pngData(), forKey: .data)
//            try container.encode(image.scale, forKey: .scale)
//        }
//    }
//}
