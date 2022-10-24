//
//  MomentRoutes.swift
//  vnvce
//
//  Created by Kerem Cesme on 24.10.2022.
//

import Foundation

enum MomentRoute {
    case upload
    case moments
    
    var raw: String {
        switch self {
        case .upload:
            return "\(MainRoute.moment)/upload"
        case .moments:
            return "\(MainRoute.moment)/fetch"
        }
    }
}
