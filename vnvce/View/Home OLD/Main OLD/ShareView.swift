//
//  ShareView.swift
//  vnvce
//
//  Created by Kerem Cesme on 1.11.2022.
//

import SwiftUI
import SwiftUIX
import PureSwiftUI

struct ShareView: View {
    @EnvironmentObject private var currentUserVM: CurrentUserViewModel
    @EnvironmentObject private var uploadVM: UploadMomentViewModel
    @EnvironmentObject public var camera: CameraManager
    
    public var image: UIImage
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(camera.previewViewFrame())
            .cornerRadius(UIDevice.current.hasNotch() ? 15 : 0, style: .circular)
            .padding(.top, UIDevice.current.hasNotch() ? UIDevice.current.statusBarHeight() : 0)
    }
}
