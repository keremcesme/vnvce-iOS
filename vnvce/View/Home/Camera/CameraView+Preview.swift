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
            view.layer.cornerRadius = 25
            view.layer.cornerCurve = .continuous
            view.layer.addSublayer(camera.preview)
        }
        
        private func setUpGestures(_ context: Context) {
            let tapGesture = UITapGestureRecognizer(
                target: context.coordinator,
                action: #selector(Coordinator.tap))
            let doubleTapGesture = UITapGestureRecognizer(
                target: context.coordinator,
                action: #selector(Coordinator.doubleTap))
            
            
            tapGesture.require(toFail: doubleTapGesture)
            
            tapGesture.numberOfTapsRequired = 1
            doubleTapGesture.numberOfTapsRequired = 2
            
            view.addGestureRecognizer(tapGesture)
            view.addGestureRecognizer(doubleTapGesture)
            
        }
        
        internal class Coordinator: NSObject {
            
            private var parent: CameraPreviewView
            
            init(_ parent: CameraPreviewView) {
                self.parent = parent
            }
            
            @objc
            public func tap(_ gesture: UITapGestureRecognizer) {
                if self.parent.camera.session.isRunning {
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
            }
            
            @objc
            public func doubleTap(_ gesture: UITapGestureRecognizer) {
                if self.parent.camera.session.isRunning {
                    self.parent.camera.rotateCamera()
                }
                
            }
        }
    }
}

