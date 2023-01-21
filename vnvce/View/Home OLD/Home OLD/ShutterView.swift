//
//  ShutterView.swift
//  vnvce
//
//  Created by Kerem Cesme on 1.11.2022.
//

import SwiftUI

struct ShutterView: View {
    @EnvironmentObject public var camera: CameraManager
    
    var body: some View {
        Button(action: camera.capturePhoto){
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
}
