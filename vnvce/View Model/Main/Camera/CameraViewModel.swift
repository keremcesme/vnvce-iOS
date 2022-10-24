//
//  CameraViewModel.swift
//  vnvce
//
//  Created by Kerem Cesme on 13.10.2022.
//

import SwiftUI

class CameraViewModel: NSObject, ObservableObject {
    @Environment(\.colorScheme) var colorScheme
    
    @Published public var viewDidAppear = false
    @Published public var showCamera: Bool = false
    
    @Published public var frame: CGRect = .zero
    @Published public var size: CGSize = .zero
    
    @Published public var offset: CGSize = .zero
    @Published private(set) public var onDragging: Bool = false
    
    @Published private(set) public var cornerRadiusEnabled: Bool = true
    
    @MainActor
    @Sendable
    public func openCamera(_ frame: CGRect, _ size: CGSize) async {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        self.frame = frame
        self.size = size
        self.cornerRadiusEnabled = true
        self.onDragging = false
        try? await Task.sleep(seconds: 0.001)
        self.viewDidAppear = true
        try? await Task.sleep(seconds: 0.001)
        withAnimation(response: 0.2) {
            self.showCamera = true
        } after: {
            self.addGesture()
            withAnimation {
                self.cornerRadiusEnabled = false
            }
            self.setStatusBar()
        }
        
    }
    
    @Sendable
    public func dismiss()  {
        DispatchQueue.main.async {
            self.removeGesture()
            self.setStatusBar(true)
            withAnimation(response: 0.2) {
                self.offset = .zero
                self.showCamera = false
            } after: {
                self.viewDidAppear = false
                self.cornerRadiusEnabled = false
            }
        }
        
    }
    
}

extension CameraViewModel {
    private func setStatusBar(_ dismiss: Bool = false) {
        if !UIDevice.current.hasNotch() {
            if dismiss {
                UIDevice.current.showStatusBar()
            } else {
                UIDevice.current.hideStatusBar()
            }
        } else {
            UIDevice.current.setStatusBar(style: dismiss ? .default : .lightContent, animation: true)
        }
    }
    
    public func onChangeOnDragging(_ value: Bool) {
        self.setStatusBar(value)
//        if !UIDevice.current.hasNotch()  {
//            if value {
//                UIDevice.current.showStatusBar()
//            } else {
//                UIDevice.current.hideStatusBar()
//            }
//        }
    }
    
    
}

extension CameraViewModel: UIGestureRecognizerDelegate {
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
        rootController().view.gestureRecognizers?.removeLast()
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
        let width: CGFloat = offset.width / 2
        let height: CGFloat = offset.height / 2
        
        switch gesture.state {
        case .possible, .began:
            self.cornerRadiusEnabled = true
        case .changed:
            DispatchQueue.main.async {
                self.onDragging = true
                if offset.height > 0 {
                    self.cornerRadiusEnabled = true
                    self.offset.height = height
                    if self.offset.width != 0 {
                        self.offset.width = width
                    } else {
                        withAnimation(.spring(response: 0.2, dampingFraction: 1, blendDuration: 0)) {
                            self.offset.width = width
                        }
                    }
                } else {
                    if offset != .zero {
                        self.offset.height = 0
                        withAnimation(.spring(response: 0.2, dampingFraction: 1, blendDuration: 0)) {
                            self.offset.width = 0
                        }
                        withAnimation {
                            self.cornerRadiusEnabled = false
                        }
                    }
                }
            }
        case .ended, .cancelled, .failed:
            if offset.height >= 100 {
                self.dismiss()
            } else {
                DispatchQueue.main.async {
                    withAnimation(response: 0.2) {
                        self.offset = .zero
                    } after: {
                        self.cornerRadiusEnabled = false
                        self.onDragging = false
                    }
                }
            }
        @unknown default:
            fatalError()
        }
    }
    
}
