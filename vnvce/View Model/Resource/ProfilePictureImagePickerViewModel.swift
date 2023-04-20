
import Foundation
import Photos
import UIKit

enum PhotoLibraryConfiguration {
    case success
    case failed
    case permissionLimited
    case permissionNotDetermined
    case permissionRestricted
    case permissionDenied
    case none
    
    var buttonTitle: String {
        switch self {
        case .permissionLimited:
            return "Allow More Photos"
        case .permissionDenied:
            return "Open Settings"
        case .permissionNotDetermined:
            return "Allow"
        default:
            return ""
        }
    }
}

class ProfilePictureImagePickerViewModel: NSObject, ObservableObject, PHPhotoLibraryChangeObserver {
    
    enum AlbumType: String, Equatable {
        case all = "Recents"
        case favorites = "Favorites"
    }
    
    @Published private(set) public var configuration: PhotoLibraryConfiguration = .none
    
    @Published public var fetchResult = PHFetchResult<PHAsset>()
    @Published public var fetchFavoriteResult = PHFetchResult<PHAsset>()
    
    @Published public private(set) var favoriteAlbum: LibraryAlbum? = nil
    
    @Published public private(set) var assets = [LibraryAsset]()
    @Published public private(set) var favoriteAssets = [LibraryAsset]()
    
    @Published public private(set) var currentAlbum: AlbumType = .all
    
    override init() {
        super.init()
        Task {
            await checkAuthorizationStatus()
        }
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    public func requestLibraryAccess() async {
        _ = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        await checkAuthorizationStatus()
    }
    
    @MainActor
    public func checkAuthorizationStatus() async {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .authorized:
            self.configuration = .success
        case .limited:
            self.configuration = .permissionLimited
        case .notDetermined:
            self.configuration = .permissionNotDetermined
        case .restricted:
            self.configuration = .permissionRestricted
        case .denied:
            self.configuration = .permissionDenied
        @unknown default:
            self.configuration = .failed
        }
        
        guard configuration == .success || configuration == .permissionLimited else {
            return
        }
        
        PHPhotoLibrary.shared().register(self)
        
        await fetchAssets()
        
    }
    
    @MainActor
    private func fetchAssets() async {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        
        self.fetchResult = PHAsset.fetchAssets(with: options)
        
        var assets = [LibraryAsset]()
        
        self.fetchResult.enumerateObjects { asset, index, _ in
            let asset = LibraryAsset(asset: asset)
            assets.append(asset)
        }
        
        let favoriteAssets: [LibraryAsset] = {
            let favoriteCollection = PHAssetCollection.fetchAssetCollections(
                with: .smartAlbum,
                subtype: .smartAlbumFavorites,
                options: nil)
            
            guard let collection = favoriteCollection.firstObject else {
                return []
            }
            self.fetchFavoriteResult = PHAsset.fetchAssets(in: collection, options: options)
            
            var assets = [LibraryAsset]()
            self.fetchFavoriteResult.enumerateObjects { asset, index, _ in
                let asset = LibraryAsset(asset: asset)
                assets.append(asset)
            }
            return assets
        }()
        
        self.assets = assets
        self.favoriteAssets = favoriteAssets
    }
    
    @Sendable
    @MainActor
    public func fetchAllAssets() async {
        if currentAlbum == .favorites {
            var assets = [LibraryAsset]()
            self.fetchResult.enumerateObjects { asset, _, _ in
                let asset = LibraryAsset(asset: asset)
                assets.append(asset)
            }
            
            DispatchQueue.main.async {
                self.currentAlbum = .all
                self.assets = assets
            }
        }
        
    }
    
    @Sendable
    @MainActor
    public func fetchFavoriteAssets() async {
        if currentAlbum == .all {
            var assets = [LibraryAsset]()
            self.fetchFavoriteResult.enumerateObjects { asset, _, _ in
                let asset = LibraryAsset(asset: asset)
                assets.append(asset)
            }
            
            DispatchQueue.main.async {
                self.currentAlbum = .favorites
                self.favoriteAssets = assets
            }
        }
    }
    
    @MainActor
    public func fetchAsset(_ item: LibraryAsset) async -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        let targetWidth = 300
        option.deliveryMode = .opportunistic
        option.resizeMode = .none
        option.isSynchronous = true
        option.isNetworkAccessAllowed = true
        option.version = .current
        
        manager.requestImage(for: item.asset, targetSize: CGSize(width: targetWidth, height: targetWidth), contentMode: .aspectFit, options: option, resultHandler: {(result, info) -> Void in
            if let result = result  {
                thumbnail = result
            }
        })
        
        return thumbnail
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {}
    
    public func openSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}
