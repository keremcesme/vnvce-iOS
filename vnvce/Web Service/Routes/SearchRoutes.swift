//
//  SearchRoutes.swift
//  vnvce
//
//  Created by Kerem Cesme on 10.09.2022.
//

import Foundation

enum SearchRoute {
    case user
    
    var raw: String {
        switch self {
            case .user:
                return "\(MainRoute.search)/user/"
        }
    }
}
