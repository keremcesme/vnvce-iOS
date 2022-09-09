//
//  TabBarViewModel.swift
//  vnvce
//
//  Created by Kerem Cesme on 7.09.2022.
//

import Foundation

public enum Tab: Hashable {
    case feed
    case profile
    
    var name: String {
        switch self {
            case .feed:
                return "HomeButtonIconFill"
            case .profile:
                return "ProfileIconFill"
        }
    }
}

class TabBarViewModel: ObservableObject {
    @Published public var current: Tab = .feed
}
