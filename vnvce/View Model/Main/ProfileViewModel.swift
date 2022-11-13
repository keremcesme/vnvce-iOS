//
//  ProfileViewModel.swift
//  vnvce
//
//  Created by Kerem Cesme on 6.11.2022.
//

import SwiftUI

class ProfileViewModel: NSObject, ObservableObject {
    
    // MARK: ScrollView, Refresh and Gesture Properties
    @Published public var scrollView: UIScrollView!
    
    @Published public var isEligible: Bool = false
    @Published public var isRefreshing: Bool = false
    
    @Published public var scrollOffset: CGPoint = .zero
    @Published public var scrollStartOffset: CGFloat = 0
    
    @Published public var isScrollEnabled: Bool = true
    
    @Published public var contentOffset: CGFloat = 0
    @Published public var progress: CGFloat = 0
    
}

extension ProfileViewModel: UIGestureRecognizerDelegate {
    
    public func scrollViewConnector(_ scrollView: UIScrollView) {
        self.scrollView = scrollView
    }
    
    public func onChangeIsScrollEnabled(_ value: Bool) {
        scrollView.isScrollEnabled = value
    }
    
    // Adding Pan Gesture To UI Main Application Window
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: Adding Gesture
    public func addGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(onGestureChange))
        panGesture.delegate = self
        panGesture.maximumNumberOfTouches = 1
        rootController().view.addGestureRecognizer(panGesture)
    }
    
    // MARK: Removing When Leaving The View
    public func removeGesture() {
        rootController().view.gestureRecognizers?.removeAll()
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
    
    @objc
    func onGestureChange(gesture: UIPanGestureRecognizer) {
        if gesture.state == .cancelled || gesture.state == .ended {
            if !isRefreshing {
                if scrollOffset.y > 100 {
                    isEligible = true
                } else {
                    isEligible = false
                }
            }
        }
    }
    
    
}
