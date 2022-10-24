//
//  CameraView.swift
//  vnvce
//
//  Created by Kerem Cesme on 20.10.2022.
//

import SwiftUI
import SwiftUIX
import PureSwiftUI

struct CameraView: View {
    @EnvironmentObject private var tabBarVM: TabBarViewModel
    @EnvironmentObject public var camera: CameraManager
    @EnvironmentObject public var currentUserVM: CurrentUserViewModel
    
    @StateObject public var uploadMomentVM = UploadMomentViewModel()
    
    init() {}
    
    private func onChangeCurrentTabBar(_ value: Tab) {
        if value == .camera && !camera.sessionIsRunning {
            camera.resumeInterruptedSession()
        }
    }
    
    private func onDisappear() {
        camera.stopSession()
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                if let image = camera.image {
                    OutputView(image)
                } else {
                    InputView
                }
                Spacer()
            }
        }
    }
    
//    @ViewBuilder
//    private func OutputView(_ image: UIImage) -> some View {
//        Image(uiImage: image)
//            .resizable()
//            .aspectRatio(contentMode: .fill)
//            .frame(camera.previewViewFrame())
//            .cornerRadius(UIDevice.current.hasNotch() ? 15 : 0, style: .circular)
//            .onTapGesture {
//                self.camera.image = nil
//                self.camera.startSession()
//            }
//    }
    
}
