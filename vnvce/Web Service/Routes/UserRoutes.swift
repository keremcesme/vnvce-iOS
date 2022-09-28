//
//  UserRoutes.swift
//  vnvce
//
//  Created by Kerem Cesme on 28.09.2022.
//

import Foundation

enum UserRoute {
    case profile(userID: String)
    
    var raw: String {
        let user = MainRoute.user
        var route = "\(user)/"
        switch self {
        case let .profile(userID):
            route += "profile/\(userID)"
            return route
        }
    }
}
