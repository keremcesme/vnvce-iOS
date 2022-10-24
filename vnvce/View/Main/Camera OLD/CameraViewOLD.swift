//
//  CameraViewOLD.swift
//  vnvce
//
//  Created by Kerem Cesme on 13.10.2022.
//

import SwiftUI
import SwiftUIX
import PureSwiftUI

struct CameraRootView: View {
    @EnvironmentObject private var cameraVM: CameraViewModel
    
    var body: some View {
        ZStack {
            EmptyView()
            if cameraVM.viewDidAppear {
                EmptyView()
                if cameraVM.showCamera {
                    Color.black.opacity(0.2).ignoresSafeArea()
                }
                CameraViewOLD()
                    .ignoresSafeArea()
            }
        }
    }
}

struct CameraViewOLD: View {
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject public var cameraVM: CameraViewModel
    
    @StateObject public var camera = CameraManager()
    
    init(){}
    
    var body: some View {
        Color.black
            .overlay(alignment: .top) {
                Preview(camera)
                    .frame(camera.previewViewFrame())
                    .overlay(alignment: .bottom){
                        ZoomButtonsView
                            .padding(.bottom, 15)
                    }
                    .cornerRadius(UIDevice.current.hasNotch() ? 25 : 0, style: .circular)
                    .padding(.top, UIDevice.current.hasNotch() ? UIDevice.current.statusBarHeight() : 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Background)
            .cornerRadius(cameraVM.cornerRadiusEnabled ? UIDevice.current.screenCornerRadius : 0, style: .continuous)
            .scaleEffect(scaleEffect)
            .mask(Mask)
            .offset(cameraVM.offset)
            .offsetToPositionIf(!cameraVM.showCamera, cameraVM.frame.center)
            .ignoresSafeArea()
            .onChange(of: cameraVM.onDragging, perform: cameraVM.onChangeOnDragging)
            .onChange(of: cameraVM.showCamera) {
                if !$0 {
                    camera.stopSession()
                }
            }
    }
    
    @ViewBuilder
    var Mask: some View {
        RoundedRectangle(cameraVM.showCamera ? (cameraVM.cornerRadiusEnabled ? UIDevice.current.screenCornerRadius : 0) : 1000, style: .continuous)
            .frame(cameraVM.showCamera ? UIScreen.main.bounds.size : cameraVM.size)
            .ignoresSafeArea()
    }
    
    @ViewBuilder
    private var Background: some View {
        BlurView(style: .regular)
            .background {
                if colorScheme == .light {
                    Color.white.opacity(0.5)
                }
            }
    }
    
    private var scaleEffect: CGFloat {
        if cameraVM.showCamera {
            if cameraVM.offset.height < 0 {
                return 1.0
            } else {
                let max = UIScreen.main.bounds.width / 2
                let currentAmount = abs(cameraVM.offset.height)
                let percentage = currentAmount / max
                return 1.0 - min(percentage, 0.1)
            }
        } else {
            return 0.5
        }
    }
    
    
    
}

struct Preview: UIViewRepresentable {
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
