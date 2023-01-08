//
//  RootViewModel.swift
//  vnvce
//
//  Created by Kerem Cesme on 6.11.2022.
//

import Foundation
import SwiftUI

enum Tab {
    case home
    case profile
}

enum ExpandCameraIcon: String, CaseIterable {
    case expand = "arrow.up.left.and.arrow.down.right"
    case narrow = "arrow.down.right.and.arrow.up.left"
}

class RootViewModel: NSObject, ObservableObject {
    private let screenWidth = UIScreen.main.bounds.width
    
    @Published public var currentTab: Tab
    
    @Published public var offset: CGFloat = 0
    
    @Published private(set) var currentStatusBarStyle: UIStatusBarStyle = .darkContent
    
    @Published public var homeWillShowed: Bool = false
    @Published public var profileWillShowed: Bool = false
    
    
    override init() {
        self.currentTab = .home
        super.init()
        self.setStatusBarStyle(.lightContent, animation: false)
    }
    
    public func onChangeCurrentOffset(_ value: CGFloat) {
        DispatchQueue.main.async {
            if value > self.screenWidth / 2 {
                self.setStatusBarStyle(.default)
                if self.currentTab != .profile {
                    self.currentTab = .profile
                }
            } else {
                self.setStatusBarStyle(.lightContent)
                if self.currentTab != .home {
                    self.currentTab = .home
                }
            }
        }
    }
    
    public func onChangeOffset(_ value: CGFloat) {
        let absValue = abs(value)
        DispatchQueue.main.async {
            if UIDevice.current.hasNotch() {
                self.offset = absValue
            }

            if absValue > self.screenWidth / 2 {
                if self.currentTab != .profile {
                    self.currentTab = .profile
                    self.setStatusBarStyle(.default)
                }
            } else {
                if self.currentTab != .home {
                    self.currentTab = .home
                    self.setStatusBarStyle(.lightContent)
                }
            }
        }
    }
    
    private func setStatusBarStyle(_ style: UIStatusBarStyle, animation: Bool = true) {
        if self.currentStatusBarStyle != style {
            self.currentStatusBarStyle = style
            UIDevice.current.setStatusBar(style: style, animation: animation)
        }
    }
}

extension RootViewModel {
    
    public func showProfile() {
        if self.currentTab != .profile {
            self.currentTab = .profile
            self.profileWillShowed = true
        }
    }
    
    public func onChangeProfileWillShowed(_ value: Bool, proxy: ScrollViewProxy) {
        if value {
            self.profileWillShowed = false
            withAnimation(response: 0.2) {
                proxy.scrollTo(1)
            }
        }
    }
    
    public func showHome() {
        if self.currentTab != .home {
            self.currentTab = .home
            self.homeWillShowed = true
        }
    }
    
    public func onChangeHomeWillShowed(_ value: Bool, proxy: ScrollViewProxy) {
        if value {
            self.homeWillShowed = false
            withAnimation(response: 0.2) {
                proxy.scrollTo(0)
            }
        }
    }
}
