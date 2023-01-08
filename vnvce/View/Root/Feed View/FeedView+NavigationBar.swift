//
//  FeedView+NavigationBar.swift
//  vnvce
//
//  Created by Kerem Cesme on 15.11.2022.
//

import SwiftUI
import PureSwiftUI
import Nuke
import NukeUI

extension FeedView {
    
    @ViewBuilder
    public var NavigationBar: some View {
        LinearGradient(colors: [.black.opacity(0.5), .clear], startPoint: .top, endPoint: .bottom)
            .frame(maxWidth: .infinity)
            .frame(height: UIDevice.current.statusAndNavigationBarHeight)
            .overlay(NB_Leading, alignment: .bottomLeading)
            .overlay(NB_Trailing, alignment: .bottomTrailing)
            .ignoresSafeArea()
    }
    
    @ViewBuilder
    private var NB_Leading: some View {
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
        .padding(.leading, 17)
    }
    
    @ViewBuilder
    private var NB_Trailing: some View {
        HStack(spacing:20) {
            NB_SearchButton
            NB_ProfileButton
        }
        .padding(.trailing, 17)
    }
    
    @ViewBuilder
    private var NB_SearchButton: some View {
        Button {
            DispatchQueue.main.async {
                guard let controller = self.viewControllerHolder.value else {
                    return
                }
                
                UIDevice.current.setStatusBar(style: .default, animation: true)
                withAnimation(response: 0.25) {
                    searchVM.show = true
                }
                
                controller.present {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        if searchVM.show {
                            self.camera.stopSession()
                        }
                    }
                    
                } content: {
                    SearchView()
                        .environmentObject(searchVM)
                        .environmentObject(currentUserVM)
                        .environmentObject(camera)
                }
            }
        } label: {
            Image(systemName: "magnifyingglass.circle.fill")
                .font(.system(size: 26, weight: .medium, design: .default))
                .foregroundColor(.white)
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var NB_ProfileButton: some View {
        NavigationLink {
            ProfileView()
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
        .buttonStyle(.plain)
    }
    
}
