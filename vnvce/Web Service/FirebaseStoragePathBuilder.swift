//
//  FirebaseStoragePathBuilder.swift
//  vnvce
//
//  Created by Kerem Cesme on 23.08.2022.
//

import Foundation
import FirebaseStorage
import FirebaseSharedSwift

struct FirebaseStoragePathBuilder {
    static let shared = FirebaseStoragePathBuilder()
    
    private init() {}
    
    public func profilePicturePath(path: StorageRoute, userID: String, name: String) -> StorageReference {
        let url = path.url
        
        return Storage.storage(url: url).reference().child(userID).child(name)
    }
    
//    public func generateProfilePicturePath(userID: String, name: String) -> StorageReference {
//        let storage = Storage.storage(url: StorageRoute.profilePicture.raw).reference().child(userID).child(name)
//
//        return storage
//    }
}

