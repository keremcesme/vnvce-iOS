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

enum UploadPostMediaPhase {
    case uploading
    case success(PostMediaPayload)
}

struct StorageAPI {
    static let shared = StorageAPI()
    
    private init() {}
    
    private let pathBuilder = FirebaseStoragePathBuilder.shared
    private let userDefaults = UserDefaults.standard
    
}

// MARK: Public Methods -
extension StorageAPI {
    public func uploadProfilePicture(image: UIImage) async throws -> UploadedImage {
        return try await uploadProfilePictureTask(image)
    }
    
    public func uploadImagePost(
        _ image: UIImage,
        _ completion: @escaping (_ status: UploadPostMediaPhase, _ progress: Double) -> Void
    ) throws {
        try uploadImagePostTask(image) { status, progress in
            completion(status, progress)
        }
    }
}

// MARK: Private Methods -
private extension StorageAPI {
    private func uploadProfilePictureTask(_ image: UIImage) async throws -> UploadedImage {
        guard let userID = UserDefaults.standard.value(forKey: "currentUserID") as? String else {
            fatalError()
        }
        
        let data = try compressImage(image, size: 512 * 512)
        let name = "image-\(UUID().uuidString).jpg"
        
        let ref = pathBuilder.profilePicturePath(userID: userID, name: name)
        
        _ = try await ref.putDataAsync(data)
        
        let url = try await ref.downloadURL().absoluteString
        
        return UploadedImage(url: url, name: name)
    }
    
    private func uploadImagePostTask(
        _ image: UIImage,
        _ completion: @escaping (_ status: UploadPostMediaPhase, _ progress: Double) -> Void
    ) throws {
        guard let userID = UserDefaults.standard.value(forKey: "currentUserID") as? String else {
            fatalError()
        }
        
        let data = try compressImage(image, size: 1024 * 1024)
        let name = "image-\(UUID().uuidString).jpg"
        
        let ref = pathBuilder.postsPath(userID: userID, name: name)
        
        let task = ref.putData(data)
        task.observe(.progress) {
            if let progress = $0.progress {
                let value = progress.fractionCompleted * 100
                if value <= 95 {
                    completion(.uploading, value)
                } else {
                    completion(.uploading, 95)
                }
            }
        }
        task.observe(.success) { _ in
            ref.downloadURL { url, error in
                guard error == nil, let url = url?.absoluteString else { return }
                let media = PostMediaPayload(type: .image, name: name, url: url)
                return completion(.success(media), 95)
            }
        }
    }
    
    
    private func compressImage(_ image: UIImage, size: Int) throws -> Data {
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
