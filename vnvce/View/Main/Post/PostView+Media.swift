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

extension PostView {
    @ViewBuilder
    public var MediaView: some View {
        Image(uiImage: postsVM.selectedPost.previewImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .greedyWidth()
            .overlay(Media)
            .opacity(postsVM.selectedPost.ready ? 1 : 0.00001)
            .overlay(PostViewBlur(postsVM: postsVM, postVM: postVM))
//                    .overlay {
//                        BlurView(style: .light)
//                            .opacity(postsVM.selectedPost.show ? 0.000001 : 1)
//                    }
            .overlay {
                ZStack {
                    EmptyView()
//                            if postVM.onDragging {
//                                BlurView(style: .light)
//                            }
//
//                            if postVM.stop {
//                                BlurView(style: .light)
//                                    .overlay {
//                                        VStack {
//                                            Image(systemName: "hand.tap.fill")
//                                                .foregroundColor(.white)
//                                                .font(.system(size: 45, weight: .medium, design: .default))
//                                            Text("tap to show")
//                                                .foregroundColor(.white)
//                                                .font(.system(size: 14, weight: .regular, design: .default))
//                                        }
//                                        .shadow(radius: 0.4)
//                                    }
//                            }
                }
                .animation(.default, value: postVM.onDragging)
                .animation(.default, value: postVM.stop)
            }
//            .overlay {
//                Color.black.opacity(0.0000001)
//                    .onTapGesture {
//                        if postVM.stop {
//                            postVM.stop = false
//                            postVM.startTimer()
//                        } else {
//                            postVM.stop = true
//                            postVM.pauseTimer()
//                        }
//                    }
//            }
    }
    
    @ViewBuilder
    private var Media: some View {
        if let url = postsVM.selectedPost.post?.media.returnURL {
            ImageMedia(url)
        }
    }
    
    @ViewBuilder
    private func ImageMedia(_ url: URL) -> some View {
        LazyImage(url: url){
            if let uiImage = $0.imageContainer?.image {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .greedyWidth()
            } else {
//                ProgressView()
//                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
//                    .shadow(3)
            }
        }
        .pipeline(.shared)
        .processors([ImageProcessors.Resize(width: 1080)])
        .priority(.veryHigh)
    }
}
