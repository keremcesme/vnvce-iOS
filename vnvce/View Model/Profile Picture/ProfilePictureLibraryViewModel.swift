//
//  ProfilePictureLibraryViewModel.swift
//  vnvce
//
//  Created by Kerem Cesme on 23.08.2022.
//

import Foundation
import Photos
import UIKit

class ProfilePictureLibraryViewModel: NSObject, ObservableObject, PHPhotoLibraryChangeObserver {
    
    enum AlbumType: String, Equatable {
        case all = "Recents"
        case favorites = "Favorites"
    }
    
    @Published public private(set) var libraryStatus: LibraryStatus = .none
    
    @Published public var fetchResult = PHFetchResult<PHAsset>()
    @Published public var fetchFavoriteResult = PHFetchResult<PHAsset>()
    
    @Published public private(set) var favoriteAlbum: LibraryAlbum? = nil
    
    @Published public private(set) var assets = [LibraryAsset]()
    @Published public private(set) var favoriteAssets = [LibraryAsset]()
    
    @Published public private(set) var currentAlbum: AlbumType = .all
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    @Sendable
    public func initLibrary() async {
        switch await libraryAuthorization() {
            case let .failure(error):
                fatalError(error.localizedDescription)
            case let .success(status):
                DispatchQueue.main.async{
                    self.libraryStatus = status
                }
                guard status == .approved || status == .limited else { return }
                PHPhotoLibrary.shared().register(self)
                let (all, favorites) = await fetchAssets()
                DispatchQueue.main.async {
                    self.assets = all
                    self.favoriteAssets = favorites
                }
        }
    }
    
    private func libraryAuthorization() async -> Result<LibraryStatus, Error> {
        switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
            case .authorized:
                return .success(.approved)
            case .limited:
                return .success(.limited)
            case .denied:
                return .success(.denied)
            default:
                switch await PHPhotoLibrary.requestAuthorization(for: .readWrite) {
                    case .authorized:
                        return .success(.approved)
                    case .limited:
                        return .success(.limited)
                    case .denied:
                        return .success(.denied)
                    default:
                        let error = NSError(domain: "Error Library Permission", code: 1)
                        return .failure(error)
                }
        }
        
        
    }
    
    @MainActor
    private func fetchAssets() async -> (all: [LibraryAsset], favorites: [LibraryAsset]){
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
        
        return (assets, favoriteAssets)
    }
    
    @Sendable
    @MainActor
    public func fetchAllAssets() async {
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
    
    @Sendable
    @MainActor
    public func fetchFavoriteAssets() async {
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
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
    }
    
}
