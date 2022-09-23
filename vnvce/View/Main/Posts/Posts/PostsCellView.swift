//
//  PostsCellView.swift
//  vnvce
//
//  Created by Kerem Cesme on 22.09.2022.
//

import SwiftUI
import SwiftUIX
import PureSwiftUI
import Nuke
import NukeUI

struct PostsCellView: View {
    @StateObject var postsVM: PostsViewModel
    
    @StateObject private var scrollDelegate: PostsScrollViewModel
    
    @State private var focused: Bool = false
    @State private var ready: Bool = false
    
    @Binding private var post: Post
    
    init(post: Binding<Post>, postsVM: PostsViewModel, scrollDelegate: PostsScrollViewModel) {
        self._post = post
        self._postsVM = StateObject(wrappedValue: postsVM)
        self._scrollDelegate = StateObject(wrappedValue: scrollDelegate)
    }
    
    var body: some View {
        GeometryReader { g in
            ZStack {
                Color.primary.opacity(0.01)
                if !ready {
                    Image(uiImage: post.previewImage?.image ?? UIImage())
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(g.size)
                }
                LazyImage(url: post.media.returnURL){
                    if let uiImage = $0.imageContainer?.image {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(g.size)
                            .overlay {
                                BlurView(style: .light)
                                    .opacity(postsVM.selectedPost.show ? 0.000001 : 1)
                            }
                            .taskInit {
                                ready = true
                            }
                    } else {
                        Color.primary.opacity(0.05).shimmering()
                    }
                }
                .animation(nil)
                .pipeline(.shared)
                .processors([ImageProcessors.Resize(width: 1080)])
                .priority(.veryHigh)
            }
            .background(OffsetTracker)
            .overlay {
                ZStack{
                    EmptyView()
                    if !focused {
                        BlurView(style: .light)
//                            .overlay {
//                                Color.black.opacity(0.3)
//                            }
                    }
                }
            }
        }
        .frame(imageContainerSize)
    }
    
    private var imageContainerSize: CGSize {
        let screenWidth = UIScreen.main.bounds.width
        
        let ratio: CGFloat = CGFloat(post.media.ratio)
        
        return CGSize(screenWidth, screenWidth * ratio)
    }
    
    @ViewBuilder
    private var OffsetTracker: some View {
        GeometryReader{ g -> Color in
            let globalOffset = g.frame(in: .global).minY
            let postHeight = g.size.height
            let screenHeight = UIScreen.main.bounds.height
            let postTopStartOffset = -(globalOffset - screenHeight / 3)
            let postBottomEndOffset = -(globalOffset + postHeight - screenHeight / 3)
            DispatchQueue.main.async {
                if !scrollDelegate.onDragging {
                    if postTopStartOffset > 0 && postBottomEndOffset < 0 && postsVM.selectedPost.ready {
                        if !self.focused {
                            withAnimation(.default) {
                                self.focused = true
                            }
                        }
                    } else {
                        if self.focused {
                            withAnimation(.default) {
                                self.focused = false
                            }
                        }
                        
                    }
                }
            }
            return Color.clear
        }
    }
}
