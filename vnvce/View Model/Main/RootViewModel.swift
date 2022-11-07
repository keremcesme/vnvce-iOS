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

class RootViewModel: NSObject, ObservableObject {
    private let screenWidth = UIScreen.main.bounds.width
    @Published public var currentTab: Tab
    
    @Published public var offset: CGFloat = 0
    
    @Published public var currentOffset: CGFloat = 0
    
    @Published private(set) var onDragging: Bool = false
    
    @Published private(set) var currentStatusBarStyle: UIStatusBarStyle = .darkContent
    
    // MARK: Home View Variables
    
    // MARK: Profile View Properties -
    @Published public var profileScrollView: UIScrollView!
    @Published public var profilePullToRefreshIsEligible: Bool = false
    @Published public var profileIsRefreshing: Bool = false
    @Published public var profileScrollOffset: CGFloat = 0
    @Published public var profilePagingIsEligible: Bool = false
    // MARK: -
    
    override init() {
        self.currentTab = .home
        super.init()
        self.setStatusBarStyle(.lightContent, animation: false)
    }
    
    public func onChangeCurrentOffset(_ value: CGFloat) {
        if value > self.screenWidth / 2 {
            setStatusBarStyle(.default)
        } else {
            setStatusBarStyle(.lightContent)
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
    
    @objc
    func dragGesture(_ gesture: UIPanGestureRecognizer) {
        let state = gesture.state
        let x = gesture.translation(in: gesture.view).x
        let velo = gesture.velocity(in: gesture.view)
        
        switch self.currentTab {
        case .home:
            homeDragGesture(state, x, velo.x)
        case .profile:
            profileDragGesture(state, x, velo)
        }
    }
    
    private func homeDragGesture(
        _ state: UIGestureRecognizer.State,
        _ x: CGFloat,
        _ velo: CGFloat
    ) {
        switch state {
        case .possible, .began:
            self.onDragging = true
        case .changed:
            DispatchQueue.main.async  {
                if x <= 0 {
                    self.offset = x
                } else {
                    self.offset = 0
                }
            }
        case .ended, .cancelled, .failed:
            DispatchQueue.main.async {
                self.onDragging = false
                if (abs(velo) >= 700 && abs(x) >= 5) || self.currentOffset > self.screenWidth / 2 {
                    self.showProfile()
                } else {
                    self.showHome()
                }
            }
        @unknown default:
            self.onDragging = false
        }
    }
    
    private func profileDragGesture(
        _ state: UIGestureRecognizer.State,
        _ x: CGFloat,
        _ velo: CGPoint
    ) {
        switch state {
        case .possible, .began:
            self.onDragging = true
            let angle = atan2(velo.y, velo.x) * 180 / 3.14159
            if angle <= 45 && angle >= -45 {
                self.profileScrollView.isScrollEnabled = false
                self.profilePagingIsEligible = true
            } else {
                self.profilePagingIsEligible = false
            }
        case .changed:
            DispatchQueue.main.async  {
                if self.profilePagingIsEligible {
                    if x >= 0 {
                        self.offset = -self.screenWidth + x
                    } else {
                        self.offset = -self.screenWidth
                    }
                }
            }
        case .ended, .cancelled, .failed:
            DispatchQueue.main.async {
                self.onDragging = false
                self.profileScrollView.isScrollEnabled = true
                switch self.profilePagingIsEligible  {
                case true:
                    if (abs(velo.x) >= 700 && x >= 5) || self.currentOffset < self.screenWidth / 2 {
                        self.showHome()
                    } else {
                        self.showProfile()
                    }
                case false:
                    if !self.profileIsRefreshing {
                        if self.profileScrollOffset > 100 {
                            self.profilePullToRefreshIsEligible = true
                        } else {
                            self.profilePullToRefreshIsEligible = false
                        }
                    }
                }
            }
        @unknown default:
            self.onDragging = false
            self.profileScrollView.isScrollEnabled = true
        }
    }
    
    public func showProfile() {
        if self.currentTab != .profile {
            self.currentTab = .profile
        }
        setStatusBarStyle(.default)
        withAnimation(.spring(response: 0.3, dampingFraction: 1, blendDuration: 0)) {
            self.offset = -self.screenWidth
        }
    }
    
    public func showHome() {
        if self.currentTab != .home {
            self.currentTab = .home
        }
        setStatusBarStyle(.lightContent)
        withAnimation(.spring(response: 0.3, dampingFraction: 1, blendDuration: 0)) {
            self.offset = 0
        }
    }
}

extension RootViewModel: UIGestureRecognizerDelegate {
    
    // MARK: Adding Gesture
    public func addGestureToProfile() {
        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(dragGesture))
        dragGesture.delegate = self
        dragGesture.maximumNumberOfTouches = 1
        rootController().view.addGestureRecognizer(dragGesture)
    }
    
    // MARK: Removing When Leaving The View
    public func removeProfileGesture() {
        rootController().view.gestureRecognizers?.removeLast()
    }
    
    // MARK: Finding Root Controller
    func rootController() -> UIViewController {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = screen.windows.first?.rootViewController
        else {
            return .init()
        }
        
        return root
    }
    
    // Adding Pan Gesture To UI Main Application Window
    internal func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

struct RootViewXOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct RootViewModifier: ViewModifier {
    private let key = RootViewXOffsetKey.self
    
    private var proxy: GeometryProxy
    
    @Binding private var value: CGFloat
    
    init(_ proxy: GeometryProxy, _ value: Binding<CGFloat>) {
        self.proxy = proxy
        self._value = value
    }
    
    func body(content: Content) -> some View {
        content
            .preference(key: key, value: proxy.frame(in: .global).minX)
            .onPreferenceChange(key) { value = -$0 }
    }
}
