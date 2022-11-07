//
//  MainView.swift
//  vnvce
//
//  Created by Kerem Cesme on 31.10.2022.
//

import SwiftUI
import SwiftUIX
import PureSwiftUI
import Nuke
import NukeUI

struct MainView: View {
    @EnvironmentObject private var searchVM: SearchViewModel
    @EnvironmentObject private var tabBarVM: TabBarViewModel
    @EnvironmentObject private var currentUserVM: CurrentUserViewModel
    @EnvironmentObject public var camera: CameraManager
    
    @StateObject private var uploadVM = UploadMomentViewModel()
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Color.black.ignoresSafeArea()
                RootView
            }
            .ignoresSafeArea()
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar(ToolBar)
            .onAppear {
                UIDevice.current.setStatusBar(style: .lightContent, animation: false)
                
            }
        }
    }
    
    @ViewBuilder
    private var RootView: some View {
        if let image = camera.image {
            ShareMomentView(image)
        } else {
            CaptureAndMomentsView
        }
    }
    
    @ViewBuilder
    private var CaptureAndMomentsView: some View {
        switch UIDevice.current.hasNotch() {
        case true:
            VStack(spacing: 15) {
                CameraViewOLD()
                TestView
                Spacer()
            }
            
        case false:
            CameraViewOLD()
                .overlay(alignment: .bottom) {
                    TestView
                }
        }
    }
    
    @ViewBuilder
    private func ShareMomentView(_ image: UIImage) -> some View {
        switch UIDevice.current.hasNotch() {
        case true:
            VStack(spacing: 15) {
                ShareView(image: image)
                
                
                HStack {
                    Button {
                        self.camera.exportImage { image in
                            DispatchQueue.main.async {
                                let saver = ImageSaver()
                                saver.writeToPhotoAlbum(image: image)
                            }
                        }
                    } label: {
                        Text("Save")
                            .padding()
                    }
                    
                    Text("\(uploadVM.progress)")
                        .foregroundColor(.red)
                        .font(.title)
                    
                    Button {
                        self.camera.exportImage { image in
                            Task {
                                await uploadVM.uploadMoment(image: image)
                            }
                        }
                    } label: {
                        Text("Share")
                            .padding()
                    }
                }

                Spacer()
            }
        case false:
            ShareView(image: image)
                .overlay(alignment: .bottom) {
                    HStack {
                        Button {
                            self.camera.exportImage { image in
                                DispatchQueue.main.async {
                                    let saver = ImageSaver()
                                    saver.writeToPhotoAlbum(image: image)
                                }
                            }
                        } label: {
                            Text("Save")
                                .padding()
                        }
                        
                        Text("\(uploadVM.progress)")
                            .foregroundColor(.red)
                            .font(.title)
                        
                        Button {
                            self.camera.exportImage { image in
                                Task {
                                    await uploadVM.uploadMoment(image: image)
                                }
                            }
                        } label: {
                            Text("Share")
                                .padding()
                        }
                    }
                }
        }
    }
    
    @ViewBuilder
    private var TestView: some View {
        ZStack(alignment: .leading) {
            GeometryReader { g in
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 15) {
                            ForEach((1...24), id: \.self){ item in
                                Button {
                                    withAnimation {
                                        proxy.scrollTo(item, anchor: .trailing)
                                    }
                                } label: {
                                    RoundedRectangle(15, style: .continuous)
                                        .foregroundColor(.white)
                                        .frame(70, 70)
                                        .opacity(0.1)
                                        .overlay {
                                            Text("\(item)")
                                                .foregroundColor(.white)
                                                .font(.title.bold())
                                        }
                                }
                                .buttonStyle(.plain)
                                .id(item)
                            }
                        }
                        .padding(.leading, 80)
                        .padding(.horizontal, 15)
                    }
                }
                
            }
            .frame(maxWidth: .infinity)
            .frame(height: 70)
            .cornerRadius(100, corners: .topLeft)
            .cornerRadius(100, corners: .bottomLeft)
            ShutterView()
        }
        .padding(.leading, 15)
    }
}

extension MainView {
    
    @ToolbarContentBuilder
    private var ToolBar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) { NavigationLeading }
        ToolbarItem(placement: .navigationBarTrailing) { NavigationTrailing }
//        ToolbarItem(placement: .navigationBarTrailing) { ProfileButton }
    }
    
    @ViewBuilder
    private var NavigationLeading: some View {
        if camera.image == nil {
            LOGO
        } else {
            DismissOutputButton
        }
    }
    
    @ViewBuilder
    private var NavigationTrailing: some View {
        if camera.image == nil {
            HStack(spacing: 20) {
                SearchButton
                ProfileButton
            }
        } else {
            
        }
    }
    
    @ViewBuilder
    private var LOGO: some View {
        HStack {
            Image("vnvceLOGO")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(22)
            Text("vnvce".lowercased())
                .font(.system(size: 34, weight: .heavy, design: .default))
                .foregroundColor(.white)
                .yOffset(-4)
        }
    }
    
    @ViewBuilder
    private var DismissOutputButton: some View {
        Button {
            self.camera.image = nil
            self.camera.startSession()
        } label: {
            Image(systemName: "xmark")
                .font(.title2)
                .foregroundColor(.white)
        }
    }
    
    @ViewBuilder
    private var SearchButton: some View {
        Button {
            DispatchQueue.main.async {
                searchVM.show = true
            }
        } label: {
            Image(systemName: "magnifyingglass.circle.fill")
                .font(.system(size: 26, weight: .medium, design: .default))
                .foregroundColor(.white)
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var ProfileButton: some View {
        NavigationLink {
            ProfileViewOLD()
        } label: {
            if let url = currentUserVM.user?.profilePicture?.url {
                LazyImage(url: URL(string: url)) { state in
                    if let uiImage = state.imageContainer?.image {
                        Circle()
                            .foregroundColor(.white)
                            .frame(35)
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(33)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .foregroundColor(.white)
                            .frame(35)
                            .shimmering()
                    }
                }
                .pipeline(.shared)
                .processors([ImageProcessors.Resize(width: 33)])
                .priority(.veryHigh)
            } else {
                Circle()
                    .foregroundColor(.white)
                    .frame(35)
                    .shimmering()
            }
        }
        .isDetailLink(false)
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}


extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}
