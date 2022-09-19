//
//  PostView+Media.swift
//  vnvce
//
//  Created by Kerem Cesme on 20.09.2022.
//

import SwiftUI
import SwiftUIX
import PureSwiftUI
import Nuke
import NukeUI

extension PostRootView {
    @ViewBuilder
    public var MediaView: some View {
        Image(uiImage: postsVM.selectedPost.previewImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .greedyWidth()
            .overlay(Media)
            .opacity(postsVM.selectedPost.ready ? 1 : 0.00001)
    }
    
    @ViewBuilder
    private var Media: some View {
        if let url = postsVM.selectedPost.post?.media.returnURL {
            ImageMedia(url)
        }
    }
    
    @ViewBuilder
    private func ImageMedia(_ url: URL) -> some View {
        LazyImage(source: url){
            if let uiImage = $0.imageContainer?.image {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .greedyWidth()
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .shadow(3)
            }
        }
        .pipeline(.shared)
        .processors([ImageProcessors.Resize(width: 1080)])
        .priority(.veryHigh)
    }
}
