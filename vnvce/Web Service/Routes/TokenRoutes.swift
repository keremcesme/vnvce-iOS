//
//  TokenRoutes.swift
//  vnvce
//
//  Created by Kerem Cesme on 22.08.2022.
//

import Foundation

enum TokenRoute {
    case generate
    
    var raw: String {
        switch self {
            case .generate:
                return "\(MainRoute.token)/generate"
        }
    }
}
