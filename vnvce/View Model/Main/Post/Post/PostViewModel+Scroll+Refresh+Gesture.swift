//
//  PostViewModel+Scroll+Refresh+Gesture.swift
//  vnvce
//
//  Created by Kerem Cesme on 24.09.2022.
//

import SwiftUI

extension PostViewModel: UIGestureRecognizerDelegate {
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
    public func addGesture(_ dismiss: @escaping DismissPostViewAction) {
        self.dismiss = dismiss
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
    private func rootController() -> UIViewController {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = screen.windows.first?.rootViewController
        else {
            return .init()
        }
        
        return root
    }
    
    @objc
    private func onGestureChange(gesture: UIPanGestureRecognizer) {
        let offset = gesture.translation(in: gesture.view)
        let width: CGFloat = offset.width / 1.5
        let height: CGFloat = offset.height / 1.5
        
        switch gesture.state {
        case .possible, .began:
            let velocity = gesture.velocity(in: gesture.view)
            let angle = atan2(velocity.y, velocity.x) * 180 / 3.14159
            self.scrollStartOffset = scrollOffset.y
            if (angle <= 55 && angle >= -55) {
                isScrollEnabled = false
            }
        case .changed:
            DispatchQueue.main.async {
                if !self.isScrollEnabled {
                    let size = CGSize(width, height)
                    self.offset = size
                    self.onDragging = true
                }
            }
        case .ended, .cancelled, .failed:
            if !isRefreshing {
                if scrollOffset.y > 100 {
                    isEligible = true
                } else {
                    isEligible = false
                }
            }
            DispatchQueue.main.async {
                if self.onDragging {
                    if width >= 50 || height >= 50 {
                        if let dismiss = self.dismiss {
                            dismiss()
                        }
                    } else {
                        let animation: Animation = .spring(response: 0.25, dampingFraction: 1, blendDuration: 0)
                        withAnimation(animation) {
                            self.offset = .zero
                        }
                    }
                    self.onDragging = false
                    self.isScrollEnabled = true
                }
            }
        @unknown default:
            fatalError()
        }
    }
}
