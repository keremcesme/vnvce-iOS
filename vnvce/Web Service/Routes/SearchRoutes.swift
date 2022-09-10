//
//  SearchRoutes.swift
//  vnvce
//
//  Created by Kerem Cesme on 10.09.2022.
//

import Foundation

enum SearchRoute {
    case user(String)
    
    var raw: String {
        switch self {
            case let .user(term):
                return "\(MainRoute.search)/user/\(term)"
        }
    }
}
