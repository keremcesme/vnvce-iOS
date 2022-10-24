//
//  CameraView+Preview.swift
//  vnvce
//
//  Created by Kerem Cesme on 20.10.2022.
//

import SwiftUI
import SwiftUIX
import PureSwiftUI

extension CameraView {
 
    @ViewBuilder
    public var InputView: some View {
        if UIDevice.current.hasNotch() {
            VStack(spacing:15) {
                PreviewUI
                    .overlay(FlashButton, alignment: .top)
                    .overlay(ZoomButtons, alignment: .bottom)
                ZStack {
                    Shutter
                    RotateButton
                }
            }
        } else {
            PreviewUI
                .overlay(FlashButton, alignment: .top)
                .overlay(alignment: .bottom) {
                    VStack(spacing: 15) {
                        ZoomButtons
                        ZStack {
                            Shutter
                            RotateButton
                        }
                    }
                    .padding(.bottom, 15)
                }
                .ignoresSafeArea()
        }
    }
    
    @ViewBuilder
    private var PreviewUI: some View {
        Preview(camera)
            .frame(camera.previewViewFrame())
            .cornerRadius(UIDevice.current.hasNotch() ? 15 : 0, style: .circular)
            .overlay(FocusView)
            .overlay(GestureView)
            
    }
    
    @ViewBuilder
    private var GestureView: some View {
        TappableView { point, taps in
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
    private var Shutter: some View {
        Button(action: camera.capturePhoto) {
            ZStack {
                BlurView(style: .systemUltraThinMaterialDark)
                    .frame(width: 77, height: 77, alignment: .center)
                    .clipShape(Circle())
                Circle()
                    .strokeBorder(.white, lineWidth: 6)
                    .foregroundColor(Color.clear)
                    .frame(width: 80, height: 80, alignment: .center)
            }
            .scaleEffect(camera.shutterAnimation ? 0.7 : 1)
            .animation(.easeInOut(duration: 0.2), value: camera.shutterAnimation)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        
    }
    
    @ViewBuilder
    private var RotateButton: some View {
        HStack {
            Spacer()
            GeometryReader { g in
                ZStack {
                    Color.black.opacity(0.0001)
                        .frame(g.size)
                    Button(action: camera.rotateCamera) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 21, weight: .medium, design: .default))
                            .foregroundColor(.white)
                            .frame(width: 37, height: 37, alignment: .center)
                            .background(BlurView(style: .dark).cornerRadius(.infinity))
                    }
                }
            }
            .frame(width: UIScreen.main.bounds.width / 2 - 40, height: 80)
        }
    }
    
    @ViewBuilder
    private var FlashButton: some View {
        Button {
            camera.flashOn.toggle()
        } label: {
            Image(systemName: camera.flashOn ? "bolt.fill" : "bolt.slash.fill")
                .font(.system(size: 24))
                .foregroundColor(.white)
                .shadow(radius: 4)
                .frame(width: 37, height: 37, alignment: .center)
        }
        .padding(.top, 15)
    }
    
    private struct Preview: UIViewRepresentable {
        @StateObject var camera: CameraManager
        
        init(_ camera: CameraManager) {
            self._camera = StateObject(wrappedValue: camera)
        }
        
        func makeUIView(context: Context) -> UIView {
            let view = UIView()
            
            view.frame = camera.preview.frame
            view.backgroundColor = .clear
            view.layer.addSublayer(camera.preview)
            
            return view
        }
        
        func updateUIView(_ uiView: UIView, context: Context) { }
    }
    
    struct TappableView: UIViewRepresentable {
        var tappedCallback: ((CGPoint, Int) -> Void)
        
        func makeUIView(context: UIViewRepresentableContext<TappableView>) -> UIView {
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
        
        func makeCoordinator() -> TappableView.Coordinator {
            return Coordinator(tappedCallback:self.tappedCallback)
        }
        
        func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<TappableView>) {
        }
        
    }
}
