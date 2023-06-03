
import SwiftUI
import VNVCECore
import SDWebImageSwiftUI

struct MomentViewModel: Identifiable {
    public var pictureManager = ImageManager()
    
    public let id: UUID
    public let message: String?
    public let mediaType: MediaType
    public let url: String
    public let thumbnailURL: String?
    public let sensitiveContent: Bool
    public let createdAt: TimeInterval
    
    public var imageDownloadState: ImageDownloadState = .nothing
    
    init(moment: Moment.Public) {
        self.id = moment.id
        self.message = moment.message
        self.mediaType = moment.mediaType
        self.url = moment.url
        self.thumbnailURL = moment.thumbnailURL
        self.sensitiveContent = moment.sensitiveContent
        self.createdAt = moment.createdAt
        
        pictureManager.cacheType = .disk
    }
    
//    public mutating func downloadImage() async {
//        print("here")
//        imageDownloadState = .downloading
//
//        let url: URL? = URL(string: url)
//
//        let image: UIImage = await withCheckedContinuation{ continuation in
//            pictureManager.load(url: url)
//            pictureManager.setOnSuccess { image, _, _ in
//                return continuation.resume(returning: image)
//            }
//        }
//
//        imageDownloadState = .downloaded(image)
//
//    }
    
}
