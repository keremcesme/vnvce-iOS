//
//  PostsScrollViewModel.swift
//  vnvce
//
//  Created by Kerem Cesme on 22.09.2022.
//

import SwiftUI
import PureSwiftUIDesign

typealias DismissPostsViewAction = () -> Void

class PostsScrollViewModel: NSObject, ObservableObject {
    
//    @Published var isEligible: Bool = false
    
    // MARK: Ofsets and Progress
    @Published public var scrollOffset: CGFloat = 0
    @Published private var scrollStartOffset: CGFloat = 0
    
    @Published public var contentOffset: CGSize = .zero
    
    @Published private(set) public var scrollIsDisabled: Bool = false
    @Published private var scrollCannotBeDisabled: Bool = false
    
    @Published private(set) public var onDragging: Bool = false
    
    private var dismiss: DismissPostsViewAction!
    
}

extension PostsScrollViewModel: UIGestureRecognizerDelegate {
    // Adding Pan Gesture To UI Main Application Window
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: Adding Gesture
    public func addGesture(_ dismiss: @escaping DismissPostsViewAction) {
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
            self.scrollStartOffset = scrollOffset
            if (angle <= 50 && angle >= -50) {
                scrollIsDisabled = true
            }
        case .changed:
            DispatchQueue.main.async {
                if self.scrollIsDisabled {
                    self.onDragging = true
                    let size = CGSize(width, height)
                    self.contentOffset = size
                } else if self.scrollStartOffset.asInt == 0 {
                    if offset.height > 0 && !self.scrollCannotBeDisabled{
                        self.scrollIsDisabled = true
                    } else {
                        self.scrollCannotBeDisabled = true
                    }
                }
            }
        case .ended, .cancelled, .failed:
            DispatchQueue.main.async {
                if self.scrollIsDisabled {
                    if width >= 50 || height >= 50 {
                        self.dismiss()
                    } else {
                        let animation: Animation = .spring(response: 0.25, dampingFraction: 1, blendDuration: 0)
                        withAnimation(animation) {
                            self.contentOffset = .zero
                        }
                    }
                    self.scrollIsDisabled = false
                    print(self.scrollIsDisabled)
                }
                self.scrollCannotBeDisabled = false
                self.onDragging = false
            }
        @unknown default:
            fatalError()
        }
        
    }
}
