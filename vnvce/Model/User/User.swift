
import Foundation
import SwiftUI
import VNVCECore

struct PublicUser: Equatable, Hashable {
    var detail: User.Public
    var imageDownloadState: ImageDownloadState = .nothing
    
    enum ImageDownloadState: Equatable, Hashable {
        case nothing
        case downloading
        case downloaded(UIImage)
    }
}

struct User {
    typealias Public = VNVCECore.User.V1.Public
    typealias Private = VNVCECore.User.V1.Private
}

extension VNVCECore.User.V1.Public {
    var convertToPublicUser: PublicUser {
        return .init(detail: self)
    }
}

extension Array where Element == VNVCECore.User.V1.Public {
    var convertToPublicMoment: [PublicUser] {
        return self.map { value in
            value.convertToPublicUser
        }
    }
}
