//
//  CameraViewOLD+ZoomButtons.swift
//  vnvce
//
//  Created by Kerem Cesme on 20.10.2022.
//

import SwiftUI
import SwiftUIX
import PureSwiftUI

extension CameraViewOLD {
    
    @ViewBuilder
    public var ZoomButtons: some View {
        
        if camera.cameraPosition == .back {
            HStack(spacing:0){
                if camera.ultraWideIsSupported {
                    ZoomButton("0.5", mode: .ultrawide)
                }
                if camera.backCameraType != .wide {
                    ZoomButton("1", mode: .wide)
                }
                
                if camera.telephotoZoomFactor != nil, let factor = camera.device.telephotoZoomFactor {
                    ZoomButton(factor, mode: .telephoto)
                }
                if camera.secondTelephotoZoomFactor != nil, let factor = camera.device.secondTelephotoZoomFactor {
                    ZoomButton(factor, mode: .telephoto)
                }
            }
            .padding(3)
            .background {
                Color.black.opacity(0.2)
                    .clipShape(Capsule())
            }
            .animation(.default, value: camera.backCameraMode)
            .padding(.bottom, 15)
        }
        
        
    }
    
    @ViewBuilder
    public func ZoomButton(_ value: String, mode: BackCameraMode) -> some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            switch mode {
            case .ultrawide:
                camera.setUltraWideMode()
            case .wide:
                camera.setWideMode()
            case .telephoto:
                camera.setTelephotoMode()
            case .secondTelephoto:
                camera.setSecondTelephotoMode()
            }
        } label: {
            GeometryReader { g in
                ZStack {
                    Color.black.opacity(0.0000001)
                    ZStack {
                        Circle()
                            .foregroundColor(.black)
                            .opacity(0.4)
                        HStack(spacing:0) {
                            Text(value)
                            if mode == camera.backCameraMode {
                                Text("x")
                            }
                        }
                        .font(.system(size: 12, weight: .semibold, design: .default))
                        .foregroundColor(mode == camera.backCameraMode ? .white : .secondary)
                        .colorScheme(.dark)
                    }
                    .scaleEffect(mode == camera.backCameraMode ? 1 : 0.7)
                }
                .frame(g.size)
                
            }
            .frame(width: 37, height: 37)
            .contentShape(Rectangle())
        }
    }
    
}
