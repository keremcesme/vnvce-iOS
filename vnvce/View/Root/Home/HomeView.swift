//
//  HomeView.swift
//  vnvce
//
//  Created by Kerem Cesme on 6.11.2022.
//

import SwiftUI
import SwiftUIX
import PureSwiftUI
import Nuke
import NukeUI

struct HomeView: View {
    @EnvironmentObject public var rootVM: RootViewModel
    @EnvironmentObject public var currentUserVM: CurrentUserViewModel
    @EnvironmentObject public var searchVM: SearchViewModel
    @EnvironmentObject public var camera: CameraManager
    
    private var size: CGSize
    
    init(size: CGSize) {
        self.size = size
    }
    
    var body: some View {
        GeometryReader{
            let size = $0.size
            NavigationView {
                VStack {
                    CameraView()
                    Text("Camera View")
                        .foregroundColor(.white)
                    Spacer()
                }
                .ignoresSafeArea()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(ToolBar)
            }
            
        }
        .frame(width: size.width / 2, height: size.height)
    }
}

extension HomeView {
    @ToolbarContentBuilder
    private var ToolBar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) { NavigationLeading }
        ToolbarItem(placement: .navigationBarTrailing) { NavigationTrailing }
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
        Button {
            self.rootVM.showProfile()
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
    }
}
