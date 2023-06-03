
import SwiftUI
import CoreMedia
import Photos
import VNVCECore

extension MomentAudience {
    var title: String {
        switch self {
        case .friendsOnly: return "Friends Only"
        case .friendsOfFriends: return "Friends of Friends"
        case .nearby: return "Nearby"
        }
    }
    
    var description: String {
        switch self {
        case .friendsOnly: return "Only friends can see it."
        case .friendsOfFriends: return "Friends and friends of friends can see it."
        case .nearby: return "Friends, friends of friends, and people nearby where the moment was shared can see it.\rNo one can see the location."
        }
    }
    
    var icon: String {
        switch self {
        case .friendsOnly: return "person.2.fill"
        case .friendsOfFriends: return "person.3.fill"
        case .nearby: return "location.fill"
        }
    }
}

@MainActor
class ShareMomentViewModel: ObservableObject {
    private let momentAPI = MomentAPI()
    private let storageAPI = StorageAPI()
    
    @Published public var view = ViewStatus()
    
    @Published public var capturedPhoto: CapturedPhoto
    
    @Published public var animationDuration: Double = 0.21
    
    @Published public var viewWillAppear: Bool = false
    @Published public var viewWillDisappear: Bool = false
    
    @Published private(set) public var imageIsSaving: Bool = false
    @Published private(set) public var imageDidSaved: Bool = false
    
    @Published public var showAudienceSheet: Bool = false
    @Published public var selectedAudience: MomentAudience = .friendsOnly
    
    @Published public var showLocationAlert: Bool = false
    
    init(_ capturedPhoto: CapturedPhoto) {
        self.capturedPhoto = capturedPhoto
    }
    
    public func setAnimation(condition: Bool = true) -> Animation? {
        if condition {
            return .spring(response: animationDuration, dampingFraction: 1, blendDuration: 0)
        } else {
            return nil
        }
    }
    
    public func initView() {
        viewWillAppear = true
    }
    
    public func deinitView(_ onSharing: Bool = true) async {
        viewWillAppear = false
        if onSharing {
            viewWillDisappear = true
            try? await Task.sleep(seconds: 0.35)
        }
        
        reset()
    }
    
    public func reset() {
        viewWillAppear = false
        viewWillDisappear = false
    }
    
}

extension ShareMomentViewModel {
    public func upload(location: MomentLocation?, message: String) async {
    
        do {
            
            guard let id = try await momentAPI.requestID() else {
                print("error")
                return
            }
            
            let url = try await storageAPI.uploadImageMoment(image: resizeImage(capturedPhoto.image), momentID: id)
            
            
            let payload: VNVCECore.UploadMomentPayload.V1 = .init(
                id: id, message: message == "" ? nil : message,
                media: .init(
                    mediaType: .image,
                    url: url,
                    thumbnailURL: nil),
                audience: selectedAudience,
                location: location)
            
            try await momentAPI.uploadMoment(payload)
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension ShareMomentViewModel {
    public func saveImage() async {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        imageIsSaving = true
        try? await Task.sleep(seconds: 0.5)
        
        let resizedImage = resizeImage(capturedPhoto.image)
        
        guard let imageData = resizedImage.jpegData(compressionQuality: 1) else {
            return
        }
        
        do {
            try await PHPhotoLibrary.shared().performChanges {
                let creationRequest = PHAssetCreationRequest.forAsset()
                creationRequest.addResource(with: .photo, data: imageData, options: nil)
            }
            
            try await Task.sleep(seconds: 0.5)
            self.imageDidSaved = true
        } catch { }
    }
    
    public func resetSaveImageValues() {
        self.imageIsSaving = false
        self.imageDidSaved = false
    }
    
    private func resizeImage(_ image: UIImage) -> UIImage {
        
        let width: CGFloat = 1440.0
        let height: CGFloat = 2160.0
        
        let canvasSize: CGSize = CGSize(width: width, height: height)
        
        let size = self.calculateImageSize(imageSize: image.size, canvasSize: canvasSize)
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        let renderer = UIGraphicsImageRenderer(size: canvasSize, format: format)
        
        let renderedImage = renderer.image { context in
            image.draw(in: size)
        }
        
        return renderedImage
    }
    
    private func calculateImageSize(imageSize: CGSize, canvasSize: CGSize) -> CGRect {
        let xScale = imageSize.width > 0 ? canvasSize.width / imageSize.width : 1
        let yScale = imageSize.height > 0 ? canvasSize.height / imageSize.height : 1
        
        let scale: CGFloat = (xScale > 0 && yScale > 0) ? max(xScale, yScale) : 1
        
        let scaledSize = CGSize(width: scale * imageSize.width, height: scale * imageSize.height)
        let size: CGRect = CGRect(
            size: CGSize(
                width: scaledSize.width,
                height: scaledSize.height),
            container: canvasSize,
            alignment: .center,
            inside: true)
        
        return size
    }
}
