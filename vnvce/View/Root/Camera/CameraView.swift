//
//  CameraView.swift
//  vnvce
//
//  Created by Kerem Cesme on 6.11.2022.
//

import SwiftUI
import SwiftUIX
import PureSwiftUI

struct CameraView: View {
    
    @EnvironmentObject public var rootVM: RootViewModel
    @EnvironmentObject public var camera: CameraManager
    
    private func blurViewOpacity() -> CGFloat {
        let width = UIScreen.main.bounds.width
        let value = abs(rootVM.offset) / (width / 2)
        if value >= 1 {
            return 1
        } else {
            return value
        }
    }
    
    internal var body: some View {
        CameraPreviewView()
            .frame(camera.previewViewFrame())
            .overlay(FocusAnimationView)
            .overlay{
                BlurView(style: .dark)
                    .opacity(blurViewOpacity())
//                    .opacity(rootVM.currentStatusBarStyle == .lightContent ? 0 : 1)
//                    .animation(.default, value: rootVM.currentStatusBarStyle)
            }
            .modifier(CornerRadiusModifier())
    }
    
    @ViewBuilder
    private var FocusAnimationView: some View {
        Circle()
            .stroke(lineWidth: 2.0)
            .foregroundColor(.white)
            .frame(width: 60, height: 60, alignment: .center)
            .opacity(camera.focusAnimation ? 0.8 : 0.000001)
            .scaleEffect(camera.focusScale)
            .position(camera.focusPosition)
            .shadow(radius: 5)
    }
    
    private struct CornerRadiusModifier: ViewModifier {
        internal func body(content: Content) -> some View {
            if UIDevice.current.hasNotch() {
                content
                    .cornerRadius(UIDevice.current.hasNotch() ? 15 : 0, corners: [.bottomRight, .bottomLeft])
            } else {
                content
            }
        }
    }
}

