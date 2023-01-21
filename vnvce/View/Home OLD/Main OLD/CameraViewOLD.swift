//
//  CameraViewOLD.swift
//  vnvce
//
//  Created by Kerem Cesme on 1.11.2022.
//

import SwiftUI
import SwiftUIX
import PureSwiftUI

struct CameraViewOLD: View {
    @EnvironmentObject public var camera: CameraManager
    
    private func tapAction(_ point: CGPoint, _ taps: Int) {
        if taps == 1 {
            camera.focusPosition = point
            withAnimation {
                camera.focusAnimation = true
                camera.focusScale = 1
            }
            camera.focusAction(point: point, size: UIDevice.current.cameraSize())
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    camera.focusAnimation = false
                    camera.focusScale = 0.8
                }
            }
        } else if taps == 2 {
            camera.rotateCamera()
        }
    }
    
    var body: some View {
        Preview()
            .frame(camera.previewViewFrame())
//            .cornerRadius(UIDevice.current.hasNotch() ? 15 : 0, style: .circular)
            .cornerRadius(UIDevice.current.hasNotch() ? 15 : 0, corners: [.bottomRight, .bottomLeft])
            .overlay(FocusView)
            .overlay(GestureView(tapAction))
            .overlay(ZoomButtons, alignment: .bottom)
            .overlay(NavigationBarBackground, alignment: .top)
            .taskInit {
                camera.startSession()
            }
    }
    
    @ViewBuilder
    private var FocusView: some View {
        Circle()
            .stroke(lineWidth: 2.0)
            .foregroundColor(.white)
            .frame(width: 60, height: 60, alignment: .center)
            .opacity(camera.focusAnimation ? 0.8 : 0.000001)
            .scaleEffect(camera.focusScale)
            .position(camera.focusPosition)
            .shadow(radius: 5)
    }
    
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
                    ZoomButton(factor, mode: .secondTelephoto)
                }
            }
            .padding(3)
            .background {
                Color.black.opacity(0.2)
                    .clipShape(Capsule())
            }
            .animation(.default, value: camera.backCameraMode)
            .padding(.bottom, UIDevice.current.hasNotch() ? 15 : 100)
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
    
    @ViewBuilder
    private var NavigationBarBackground: some View {
        LinearGradient([Color.black.opacity(0.5), Color.clear], from: .top, to: .bottom)
            .frame(maxWidth: .infinity)
            .frame(height: UIDevice.current.statusBarHeight() + 44)
            .ignoresSafeArea()
    }
    
}

private extension CameraViewOLD {
    private struct Preview: UIViewRepresentable {
        @EnvironmentObject public var camera: CameraManager
        
        func makeUIView(context: Context) -> UIView {
            let view = UIView()
            
            view.frame = camera.preview.frame
            view.backgroundColor = .clear
            view.layer.addSublayer(camera.preview)
            
            return view
        }
        
        func updateUIView(_ uiView: UIView, context: Context) { }
    }
    
    private struct GestureView: UIViewRepresentable {
        var tappedCallback: ((CGPoint, Int) -> Void)
        
        init(_ tappedCallback: @escaping ((CGPoint, Int) -> Void)) {
            self.tappedCallback = tappedCallback
        }

        func makeUIView(context: UIViewRepresentableContext<GestureView>) -> UIView {
            let v = UIView(frame: .zero)
            let gesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.tapped))
            gesture.numberOfTapsRequired = 1
            let gesture2 = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.doubleTapped))
            gesture2.numberOfTapsRequired = 2
            gesture.require(toFail: gesture2)
            
            v.addGestureRecognizer(gesture)
            v.addGestureRecognizer(gesture2)
            return v
        }

        class Coordinator: NSObject {
            var tappedCallback: ((CGPoint, Int) -> Void)
            init(tappedCallback: @escaping ((CGPoint, Int) -> Void)) {
                self.tappedCallback = tappedCallback
            }
            @objc func tapped(gesture:UITapGestureRecognizer) {
                let point = gesture.location(in: gesture.view)
                self.tappedCallback(point, 1)
            }
            @objc func doubleTapped(gesture:UITapGestureRecognizer) {
                let point = gesture.location(in: gesture.view)
                self.tappedCallback(point, 2)
            }
        }

        func makeCoordinator() -> GestureView.Coordinator {
            return Coordinator(tappedCallback:self.tappedCallback)
        }

        func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<GestureView>) {
        }

    }
}
