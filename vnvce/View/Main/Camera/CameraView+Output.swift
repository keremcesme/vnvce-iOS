//
//  CameraView+Output.swift
//  vnvce
//
//  Created by Kerem Cesme on 22.10.2022.
//

import SwiftUI
import SwiftUIX
import PureSwiftUI
import Nuke
import NukeUI

extension CameraView {
    
    @ViewBuilder
    public func OutputView(_ image: UIImage) -> some View {
        ZStack {
            if UIDevice.current.hasNotch() {
                VStack(spacing:0) {
                    OutputUI(image)
                    OutputBottomView
                }
            } else {
                OutputUI(image)
                    .overlay(OutputBottomView, alignment: .bottom)
                    .ignoresSafeArea()
            }
        }
        
    }
    
    @ViewBuilder
    private func OutputUI(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(camera.previewViewFrame())
            .cornerRadius(UIDevice.current.hasNotch() ? 15 : 0, style: .circular)
    }
    
    @ViewBuilder
    private var OutputBottomView: some View {
        HStack {
            CancelButton
            Spacer()
            SaveButton
            ShareButton
        }
        .padding(15)
    }
    
    @ViewBuilder
    private var ShareButton: some View {
        Button {
            Task {
                guard let image = self.camera.image else {
                    return
                }
                await uploadMomentVM.uploadMoment(image: image)
            }
        } label: {
            HStack(spacing: 7.5) {
                ProfilePictureView
                HStack(spacing: 4){
                    Text("Share Moment")
                        .foregroundColor(.black)
                        .font(.system(size: 9, weight: .semibold, design: .default))
                }
            }
            .frame(height: 38)
            .padding(.horizontal, 9)
            .background(ShareButtonBackground)
        }
    }
    
    @ViewBuilder
    private var CancelButton: some View {
        Button {
            self.camera.image = nil
            self.camera.startSession()
        } label: {
            Text("Cancel")
                .foregroundColor(.white)
                .font(.system(size: 9, weight: .semibold, design: .default))
            .frame(height: 38)
            .padding(.horizontal, 15)
            .background(CancelButtonBackground)
        }
    }
    
    @ViewBuilder
    private var SaveButton: some View {
        Button {
            self.camera.exportImage { image in
                DispatchQueue.main.async {
                    let saver = ImageSaver()
                    saver.writeToPhotoAlbum(image: image)
                }
            }
        } label: {
            VStack {
                Image("save")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .foregroundColor(.white)
                    .frame(width: 18, height: 18, alignment: .center)
            }
            .frame(width: 38, height: 38, alignment: .center)
            .background(SaveButtonBackground)
        }
    }
    
    @ViewBuilder
    private var ShareButtonBackground: some View {
        if UIDevice.current.hasNotch() {
            Capsule().fill(.white)
        } else {
            BlurView(style: .systemMaterialLight).clipShape(Capsule())
        }
    }
    
    @ViewBuilder
    private var CancelButtonBackground: some View {
        if UIDevice.current.hasNotch() {
            Capsule().fill(.white).opacity(0.1)
        } else {
            BlurView(style: .dark).clipShape(Capsule())
        }
    }
    
    @ViewBuilder
    private var SaveButtonBackground: some View {
        if UIDevice.current.hasNotch() {
            Circle().fill(.white).opacity(0.1)
        } else {
            BlurView(style: .dark).clipShape(Circle())
        }
    }
    
    @ViewBuilder
    private var ProfilePictureView: some View {
        LazyImage(url: profilePictureURL()) { state in
            Group {
                if let uiImage = state.imageContainer?.image {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Color.primary.opacity(0.05)
                        .shimmering()
                }
            }
            .frame(width: 24, height: 24, alignment: .center)
            .cornerRadius(.infinity)
        }
        .pipeline(.shared)
        .processors([ImageProcessors.Resize(width: 24)])
        .priority(.veryHigh)
        .overlay{
            Circle()
                .strokeBorder(Color.black, lineWidth: 1.5)
                .foregroundColor(Color.clear)
        }
    }
    
    private func profilePictureURL() -> URL {
        guard let urlString = currentUserVM.user?.profilePicture?.url else {
            let url = URL(string: "")!
            return url
        }
        let url = URL(string: urlString)!
        return url
    }
    
}
