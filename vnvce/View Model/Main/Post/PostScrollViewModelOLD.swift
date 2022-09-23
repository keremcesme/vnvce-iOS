//
//  PostScrollViewModel.swift
//  vnvce
//
//  Created by Kerem Cesme on 19.09.2022.
//

import Foundation
import SwiftUI

//typealias PostDismissAction = () -> Void
//
//// MARK: For Simultanous Pan Gesture
//class PostScrollViewModel: NSObject, ObservableObject, UIGestureRecognizerDelegate {
//    // MARK: Properties
//    @Published var isEligible: Bool = false
//    @Published var isRefreshing: Bool = false
//
//    // MARK: Ofsets and Progress
//    @Published var scrollOffset: CGPoint = .zero
//    @Published var contentOffset: CGFloat = 0
//    @Published var progress: CGFloat = 0
//
//    @Published var scrollDisabled: Bool = false
//
//    @Published var offset: CGSize = .zero
//
//    @Published var dismiss: PostDismissAction? = nil
//
//
//    // Adding Pan Gesture To UI Main Application Window
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }
//
//    // MARK: Adding Gesture
//    func addGesture() {
//        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(onGestureChange(gesture:)))
//        panGesture.delegate = self
//        panGesture.maximumNumberOfTouches = 1
//        rootController().view.addGestureRecognizer(panGesture)
//    }
//
//    // MARK: Removing When Leaving The View
//    func removeGesture() {
//        rootController().view.gestureRecognizers?.removeAll()
//    }
//
//    // MARK: Finding Root Controller
//    func rootController() -> UIViewController {
//        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//              let root = screen.windows.first?.rootViewController
//        else {
//            return .init()
//        }
//
//        return root
//    }
//
//    @objc
//    func onGestureChange(gesture: UIPanGestureRecognizer) {
//        let offset = gesture.translation(in: gesture.view)
//        let x = offset.width / 1.5
//        let y = offset.height / 1.5
//
//        if gesture.state == .cancelled || gesture.state == .ended {
//            if !isRefreshing {
//                if scrollOffset.y > 100 {
//                    isEligible = true
//                } else {
//                    isEligible = false
//                }
//            }
//
//            DispatchQueue.main.async {
//                if self.scrollDisabled {
//                    if x >= 50 || y >= 50 {
//                        if let dismiss = self.dismiss {
//                            dismiss()
//                        }
//                    } else {
//                        withAnimation(.spring(
//                            response: 0.25,
//                            dampingFraction: 1,
//                            blendDuration: 0
//                        )) {
//                            self.offset = .zero
//                        }
//                    }
//                    self.scrollDisabled = false
//                }
//            }
//
//
//        } else if gesture.state == .began {
//            let velo = gesture.velocity(in: gesture.view)
//
//            let x = velo.x
//            let y = velo.y
//
//            let angle = atan2(y, x) * 180 / 3.14159
//
//            if angle <= 50 && angle >= -50 {
//                scrollDisabled = true
//            }
//        } else {
//            DispatchQueue.main.async {
//                if self.scrollDisabled {
//                    self.offset = CGSize(x, y)
//                }
//            }
//        }
//    }
//
//}
