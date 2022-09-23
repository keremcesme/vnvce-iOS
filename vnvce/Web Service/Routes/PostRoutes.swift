//
//  PostRoutes.swift
//  vnvce
//
//  Created by Kerem Cesme on 13.09.2022.
//

import Foundation

enum PostRoute {
    case upload
    case posts(PaginationParams)
    
    var raw: String {
        switch self {
        case .upload:
            return "\(MainRoute.post)/upload"
        case let .posts(params):
            return "\(MainRoute.post)/fetch_posts/\(params.raw)"
        }
    
        
    }
}
