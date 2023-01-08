//
//  HomeView+NavigationBar.swift
//  vnvce
//
//  Created by Kerem Cesme on 11.11.2022.
//

import SwiftUI
import SwiftUIX
import PureSwiftUI
import Nuke
import NukeUI

extension HomeView {
    @ToolbarContentBuilder
    public var ToolBar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) { NavigationLeading }
        ToolbarItem(placement: .navigationBarTrailing) { NavigationTrailing }
    }
    
    @ViewBuilder
    private var NavigationLeading: some View {
        HStack(spacing: 20) {
            if camera.image == nil {
                LOGO
            }
        }
    }
    
    @ViewBuilder
    private var NavigationTrailing: some View {
        HStack(spacing: 20) {
//                Button {
//                    guard let controller = self.viewControllerHolder.value else {
//                        return
//                    }
//                    controller.present(backgroundColor: .black) {
//                        TestFeedView()
//                    }
//
//                } label: {
//                    Text("Test")
//                }

                SearchButton
                ProfileButton
            
        }
    }
}

// CAMERA VIEW
private extension HomeView {
    
    private func searchButtonAction() {
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
    private var SearchButton: some View {
        Button(action: searchButtonAction) {
            Image(systemName: "magnifyingglass.circle.fill")
                .font(.system(size: 26, weight: .medium, design: .default))
                .foregroundColor(.white)
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var ProfileButton: some View {
        Button(action: rootVM.showProfile) {
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

// OUTPUT VIEW
private extension HomeView {
    
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
}
