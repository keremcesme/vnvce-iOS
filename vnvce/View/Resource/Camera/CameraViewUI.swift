//
//  CameraView.swift
//  vnvce
//
//  Created by Kerem Cesme on 6.11.2022.
//

import SwiftUI
import SwiftUIX
import PureSwiftUI
import Colorful

struct CameraViewUI: View {
    @EnvironmentObject public var homeVM: HomeViewModel
    @EnvironmentObject public var camera: CameraManager
    
    internal var body: some View {
#if targetEnvironment(simulator)
        Color.red
            .overlay {
                Text("Simulator").foregroundColor(.black)
            }
            .frame(homeVM.momentSize)
#else
        CameraPreviewView()
            .frame(camera.previewViewFrame())
            .overlay(FocusAnimationView)
            .overlay(PermissionLayer)
#endif
    }
    
    @ViewBuilder
    private var FocusAnimationView: some View {
        if camera.session.isRunning {
            Circle()
                .stroke(lineWidth: 2.0)
                .foregroundColor(.white)
                .frame(width: 60, height: 60, alignment: .center)
                .opacity(camera.focusAnimation ? 0.8 : 0.000001)
                .scaleEffect(camera.focusScale)
                .position(camera.focusPosition)
                .shadow(radius: 5)
        }
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

