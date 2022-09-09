//
//  ProfilePictureAlignmentType.swift
//  vnvce
//
//  Created by Kerem Cesme on 23.08.2022.
//

import Foundation
import SwiftUI

enum ProfilePictureAlignmentType: String, Codable {
    case top = "top"
    case center = "center"
    case bottom = "bottom"
}

extension ProfilePictureAlignmentType {
    var convert: SwiftUI.Alignment {
        switch self {
            case .top:
                return .top
            case .center:
                return .center
            case .bottom:
                return .bottom
        }
    }
}

extension Alignment {
    var convert: ProfilePictureAlignmentType {
        switch self {
            case .top:
                return .top
            case .bottom:
                return .bottom
            default :
                return .center
                
        }
    }
    
    
}
