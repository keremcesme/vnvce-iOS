//
//  FirebaseStoragePathBuilderOLD.swift
//  vnvce
//
//  Created by Kerem Cesme on 23.08.2022.
//

import Foundation
import FirebaseStorage
import FirebaseSharedSwift

struct FirebaseStoragePathBuilderOLD {
    static let shared = FirebaseStoragePathBuilderOLD()
    
    private init() {}
    
    public func profilePicturePath(userID: String, name: String) -> StorageReference {
        let url = StorageRoute.profilePictures.url
        
        return Storage.storage(url: url).reference().child(userID).child(name)
    }
    
    public func postsPath(userID: String, name: String) -> StorageReference {
        let url = StorageRoute.posts.url
        return Storage.storage(url: url).reference().child(userID).child(name)
    }
    
    public func momentsPath(userID: String, name: String) -> StorageReference {
        let url = StorageRoute.moments.url
        return Storage.storage(url: url).reference().child(userID).child(name)
    }
//    public func generateProfilePicturePath(userID: String, name: String) -> StorageReference {
//        let storage = Storage.storage(url: StorageRoute.profilePicture.raw).reference().child(userID).child(name)
//
//        return storage
//    }
}
