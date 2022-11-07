//
//  CameraView+Preview.swift
//  vnvce
//
//  Created by Kerem Cesme on 6.11.2022.
//

import SwiftUI

extension CameraView {
    struct CameraPreviewView: UIViewRepresentable {
        @EnvironmentObject public var camera: CameraManager
        @EnvironmentObject public var rootVM: RootViewModel
        
        private let view = UIView()
        
        internal func makeUIView(context: Context) -> UIView {
            setUpPreviewView()
            setUpGestures(context)
            
            return view
        }
        
        internal func updateUIView(_ uiView: UIView, context: Context) { }
        
        internal func makeCoordinator() -> Coordinator {
            return Coordinator(self)
        }
        
        private func setUpPreviewView() {
            view.frame = camera.preview.frame
            view.backgroundColor = .clear
            view.layer.addSublayer(camera.preview)
        }
        
        private func setUpGestures(_ context: Context) {
            let tapGesture = UITapGestureRecognizer(
                target: context.coordinator,
                action: #selector(Coordinator.tap))
            let doubleTapGesture = UITapGestureRecognizer(
                target: context.coordinator,
                action: #selector(Coordinator.doubleTap))
            let dragGesture = UIPanGestureRecognizer(
                target: rootVM,
                action: #selector(rootVM.dragGesture))
            
            
            tapGesture.require(toFail: doubleTapGesture)
            
            tapGesture.numberOfTapsRequired = 1
            doubleTapGesture.numberOfTapsRequired = 2
            dragGesture.maximumNumberOfTouches = 1
            
            view.addGestureRecognizer(tapGesture)
            view.addGestureRecognizer(doubleTapGesture)
            view.addGestureRecognizer(dragGesture)
            
        }
        
        internal class Coordinator: NSObject {
            
            private var parent: CameraPreviewView
            
            init(_ parent: CameraPreviewView) {
                self.parent = parent
            }
            
            
            @objc
            public func tap(_ gesture: UITapGestureRecognizer) {
                let size = UIDevice.current.cameraSize()
                let position = gesture.location(in: gesture.view)
                DispatchQueue.main.async {
                    self.parent.camera.focusPosition = position
                    withAnimation {
                        self.parent.camera.focusAnimation = true
                        self.parent.camera.focusScale = 1
                    }
                    self.parent.camera.focusAction(point: position, size: size)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation {
                            self.parent.camera.focusAnimation = false
                            self.parent.camera.focusScale = 0.8
                        }
                    }
                }
            }
            
            @objc
            public func doubleTap(_ gesture: UITapGestureRecognizer) {
                self.parent.camera.rotateCamera()
            }
            
            @objc func dragGesture(_ gesture: UIPanGestureRecognizer) {
                let state = gesture.state
                let screenWidth = UIScreen.main.bounds.width
                let x = gesture.translation(in: gesture.view).x
                let v = gesture.velocity(in: gesture.view)
                
                DispatchQueue.main.async {
                    if gesture.state == .changed {
                        if x <= 0 {
                            self.parent.rootVM.offset = x
                        }
                        if self.parent.rootVM.currentOffset > screenWidth / 2 {
                            UIDevice.current.setStatusBar(style: .default, animation: true)
                        } else {
                            UIDevice.current.setStatusBar(style: .lightContent, animation: true)
                        }
                    } else if state == .ended || state == .cancelled || state == .failed {
//                        print("~~~~~~~")
//                        print(abs(v.x))
//                        print(x)
                        if abs(v.x) >= 700 && abs(x) >= 5 {
                            UIDevice.current.setStatusBar(style: .default, animation: true)
                            withAnimation(.spring()) {
                                self.parent.rootVM.offset = -screenWidth
                            }
                        } else if self.parent.rootVM.currentOffset > screenWidth / 2 {
                            withAnimation(.spring()) {
                                self.parent.rootVM.offset = -screenWidth
                            }
                        } else {
                            withAnimation(.spring()) {
                                self.parent.rootVM.offset = 0
                            }
                        }
                    }
                    
                }
            }
            
        }
    }
}

