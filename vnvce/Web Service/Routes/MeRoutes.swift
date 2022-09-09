//
//  MeRoutes.swift
//  vnvce
//
//  Created by Kerem Cesme on 22.08.2022.
//

import Foundation

enum MeRoute {
    case profile
    case edit(MeEditRoute)
    
    var raw: String {
        switch self {
            case .profile:
                return "\(MainRoute.me)/profile"
            case .edit(_):
                return "\(MainRoute.me)/edit"
        }
    }
}

enum MeEditRoute {
    case profilePicture
    case displayName
    case biography
    
    var raw: String {
        switch self {
            case .profilePicture:
                return "profile_picture"
            case .displayName:
                return "display_name"
            case .biography:
                return "biography"
        }
    }
    
}
