//
//  PostView+NavigationBar.swift
//  vnvce
//
//  Created by Kerem Cesme on 19.09.2022.
//

import SwiftUI
import ActionOver
import Nuke
import NukeUI

extension PostView {
    
    @ViewBuilder
    var NavigationBar: some View {
        BlurView(style: .systemMaterial)
            .frame(maxWidth: .infinity)
            .frame(height: UIDevice.current.statusAndNavigationBarHeight)
            .overlay(alignment: .bottom) {
                Divider()
            }
            .opacity(-scrollDelegate.scrollOffset.y / 10)
            .overlay(BackButton, alignment: .bottomLeading)
    }
    
    @ViewBuilder
    private var BackButton: some View {
        Button(action: dismiss) {
            HStack {
                Image(systemName: "chevron.backward")
                    .foregroundColor(.primary)
                    .font(.system(size: 20, weight: .medium, design: .default))
                    .frame(height: 44)
                    .padding(.leading, 17)
                if let url = URL(string: postsVM.selectedPost.post!.owner.owner.profilePicture!.url) {
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
