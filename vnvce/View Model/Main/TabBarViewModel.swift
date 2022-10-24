//
//  TabBarViewModel.swift
//  vnvce
//
//  Created by Kerem Cesme on 7.09.2022.
//

import Foundation

public enum Tab: Hashable {
    case feed
    case camera
    case profile
    
    var name: String {
        switch self {
        case .feed:
            return "Home"
        case .camera:
            return "Camera"
        case .profile:
            return "ProfileFill"
        }
    }
    
    var fill: String {
        switch self {
        case .feed:
            return "HomeFill"
        case .camera:
            return "CameraFill"
        case .profile:
            return "ProfileFill"
        }
    }
}

class TabBarViewModel: ObservableObject {
    @Published public var current: Tab = .feed
}
