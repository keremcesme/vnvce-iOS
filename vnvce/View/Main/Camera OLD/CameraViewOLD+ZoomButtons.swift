//
//  CameraViewOLD+ZoomButtons.swift
//  vnvce
//
//  Created by Kerem Cesme on 16.10.2022.
//

import SwiftUI

extension CameraViewOLD {
    
    @ViewBuilder
    public var ZoomButtonsView: some View {
        HStack(spacing:0){
            if camera.ultraWideIsSupported {
                ZoomButton("0.5", mode: .ultrawide)
            }
            if camera.backCameraMode != .wide {
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


//HStack {
//    if camera.ultraWideIsSupported {
//        Button {
//            camera.setUltraWideMode()
//        } label: {
//            Text("0.5")
//                .font(.system(size: 11, weight: .semibold, design: .default))
//                .foregroundColor(.white)
//        }
//        .buttonStyle(.plain)
//    }
//    if camera.captureDeviceType.type != .wide {
//        Button {
//            camera.setUltraWideMode()
//        } label: {
//            Text("1")
//                .font(.system(size: 11, weight: .semibold, design: .default))
//                .foregroundColor(.white)
//        }
//        .buttonStyle(.plain)
//    }
//
//    if let factor = camera.secondTelephotoZoomFactor {
//        Button {
//            camera.setSecondTelephotoMode()
//        } label: {
//            Text("2")
//                .font(.system(size: 11, weight: .semibold, design: .default))
//                .foregroundColor(.white)
//        }
//        .buttonStyle(.plain)
//    }
//
//    if let factor = camera.telephotoZoomFactor {
//        Button {
//            camera.setTelephotoMode()
//        } label: {
//            Text("3")
//                .font(.system(size: 11, weight: .semibold, design: .default))
//                .foregroundColor(.white)
//        }
//        .buttonStyle(.plain)
//    }
//}
//.background {
//    Color.black.opacity(0.1)
//        .clipShape(Capsule())
//}
