
import UIKit
import FirebaseStorage
import FirebaseSharedSwift
import KeychainAccess
import VNVCECore


struct FirebaseStorageRefBuilder {
    static let shared = FirebaseStorageRefBuilder()
    
    private let routes = FirebaseStorageRoutes.V1.shared
    private let endpoint = Endpoint.shared
    
    public func profilePicture(_ name: String) -> StorageReference {
        let route = routes.profilePictures
        let url = endpoint.makeFirebaseStorageURL(route)
        
        return Storage.storage(url: url).reference().child(name)
    }
    
    public func moment(_ name: String, momentID: String, userID: String) -> StorageReference {
        let route = routes.moments
        let url = endpoint.makeFirebaseStorageURL(route)
        
        return Storage.storage(url: url).reference().child(userID).child(momentID).child(name)
    }
}

enum UploadImageError: Error {
    case userIdNotFound
}

actor StorageAPI {
    private let refBuilder = FirebaseStorageRefBuilder.shared
    private let keychain = Keychain()
}

// PROFILE PICTURE
extension StorageAPI {
    func uploadProfilePicture(_ image: UIImage) async throws -> String {
        guard let userID = try keychain.get(KeychainKey.userID) else {
            throw UploadImageError.userIdNotFound
        }
        
        let data = try image.compressImage(size: 512 * 512)
        let name = userID.convertStorageName()
        
        let ref = refBuilder.profilePicture(name)
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        _ = try await ref.putDataAsync(data, metadata: metadata)
        
        let url = try await ref.downloadURL().absoluteString
        
        return url
    }
    
    func deleteProfilePicture(_ name: String) async throws {
        guard let userID = try keychain.get(KeychainKey.userID) else {
            throw UploadImageError.userIdNotFound
        }
        
        let name = userID.convertStorageName()
        
        let ref = refBuilder.profilePicture(name)
        
        try? await ref.delete()
    }
}

// MOMENT
extension StorageAPI {
    func uploadImageMoment(image: UIImage, momentID: UUID) async throws -> String {
        guard let userID = try keychain.get(KeychainKey.userID) else {
            throw UploadImageError.userIdNotFound
        }
        
        let data = try image.compressImage(size: 1024 * 1024)
        let name = momentID.uuidString.convertStorageName()
        
        let ref = refBuilder.moment(name, momentID: momentID.uuidString, userID: userID)
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        _ = try await ref.putDataAsync(data, metadata: metadata)
        
        let url = try await ref.downloadURL().absoluteString
        
        return url
    }
}
