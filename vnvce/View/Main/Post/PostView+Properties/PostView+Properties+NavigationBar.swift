//
//  PostView+Properties+NavigationBar.swift
//  vnvce
//
//  Created by Kerem Cesme on 24.09.2022.
//

import SwiftUI
import Nuke
import NukeUI

extension PostView.PostProperties {
    
    public var navigationBarAlignment: Alignment {
        switch postsVM.selectedPost.show {
        case true:
            return .top
        case false:
            return .center
        }
    }
    
    private func dismiss() {
        guard let dismiss = postVM.dismiss else {
            return
        }
        dismiss()
    }
    
    @ViewBuilder
    public var NavigationBar: some View {
        BlurView(style: .systemMaterial)
            .frame(maxWidth: .infinity)
            .frame(height: UIDevice.current.statusAndNavigationBarHeight)
            .overlay(Divider(), alignment: .bottom)
            .opacity(-postVM.scrollOffset.y / 10)
            .overlay(NavigationBar_Leading, alignment: .bottomLeading)
    }
    
    @ViewBuilder
    private var NavigationBar_Leading: some View {
        Button(action: dismiss) {
            HStack {
                Image(systemName: "chevron.backward")
                    .foregroundColor(.primary)
                    .font(.system(size: 20, weight: .medium, design: .default))
                    .frame(height: 44)
                    .padding(.leading, 17)
                if let url = currentUserVM.user?.profilePicture?.returnURL {
                    LazyImage(url: url) { state in
                        if let uiImage = state.imageContainer?.image {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 25, height: 25)
                                .mask(RoundedRectangle(cornerRadius: 6))
                        }
                    }
                    .pipeline(.shared)
                    .processors([ImageProcessors.Resize(width: 25)])
                    .priority(.normal)
                }
            }
        }
    }
    
}
