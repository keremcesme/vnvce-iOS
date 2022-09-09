//
//  UploadAPI.swift
//  vnvce
//
//  Created by Kerem Cesme on 23.08.2022.
//

import Foundation
import UIKit
import FirebaseStorage
import FirebaseSharedSwift

struct UploadedImage {
    let url: String
    let name: String
}

//typealias UploadImageResult = Result<UploadedImage, Error>

struct StorageAPI {
    static let shared = StorageAPI()
    
    private init() {}
    
    private let pathBuilder = FirebaseStoragePathBuilder.shared
    private let userDefaults = UserDefaults.standard
    
//    private let userID: String? = {
//        if let id = UserDefaults.standard.value(forKey: "currentUserID") as? String {
//            return id
//        } else {
//            return nil
//        }
//    }()
}

// MARK: Public Methods -
extension StorageAPI {
    public func uploadProfilePicture(image: UIImage) async throws -> UploadedImage {
        return try await uploadProfilePictureTask(image)
    }
}

// MARK: Private Methods -
private extension StorageAPI {
    private func uploadProfilePictureTask(_ image: UIImage) async throws -> UploadedImage {
        guard let userID = UserDefaults.standard.value(forKey: "currentUserID") as? String else {
            fatalError()
        }
        
        let data = try await compressImage(image, size: 512 * 512)
        let name = UUID().uuidString
        
        let ref = pathBuilder.profilePicturePath(path: .profilePictures, userID: userID, name: name)
        
        _ = try await ref.putDataAsync(data)
        
        let url = try await ref.downloadURL().absoluteString
        
        return UploadedImage(url: url, name: name)
    }
    
    private func compressImage(_ image: UIImage, size: Int) async throws -> Data {
        var compression: CGFloat = 1.0
        let maxCompression: CGFloat = 0.02
        
        guard var uploadImageData = image.jpegData(compressionQuality: compression) else {
            print("Compress Error")
            throw NSError(domain: "Compress Error", code: 1)
        }
        
        while (uploadImageData.count > size) && (compression > maxCompression) {
            compression -= 0.05
            if let compressedImageData = image.jpegData(compressionQuality: compression) {
                uploadImageData = compressedImageData
                print(compressedImageData.count)
            }
        }
        
        guard let data = image.jpegData(compressionQuality: compression) else {
            print("ERROR: Compressing final photo")
            throw NSError(domain: "Compressing final photo", code: 1)
        }
        
        return data
    }
}
