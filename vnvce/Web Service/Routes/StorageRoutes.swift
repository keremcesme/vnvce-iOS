//
//  StorageRoutes.swift
//  vnvce
//
//  Created by Kerem Cesme on 23.08.2022.
//

import Foundation
import FirebaseStorage
import FirebaseSharedSwift

//enum StorageRoute {
//    case profilePicture(userID: String, name: String)
//    case post(userID: String, name: String)
//
//    var ref: StorageReference {
//        var url = WebConstants.storageURL
//        switch self {
//            case let .profilePicture(userID, name):
//                url += "profile-pictures"
//                return Storage.storage(url: url).reference().child(userID).child(name)
//            case let .post(userID, name):
//                url += "posts"
//                return Storage.storage(url: url).reference().child(userID).child(name)
//        }
//    }
//
//}

enum StorageRoute {
    case profilePictures
    case posts
    case moments
    
    var url: String {
        var url = WebConstants.storageURL
        switch self {
            case .profilePictures:
                url += "profile-pictures"
                return url
            case .posts:
                url += "posts"
                return url
        case .moments:
            url += "moments"
            return url
        }
    }
    
}

