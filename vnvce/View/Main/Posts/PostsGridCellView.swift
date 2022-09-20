//
//  PostsGridCellView.swift
//  vnvce
//
//  Created by Kerem Cesme on 19.09.2022.
//

import SwiftUI
import SwiftUIX
import PureSwiftUI
import Nuke
import NukeUI

struct PostsGridCellView: View {
    @EnvironmentObject private var navigationController: NavigationController
    
    @StateObject private var postsVM: PostsViewModel
    
    @State var image = UIImage()
    
//    let url: URL
    let post: Post
    
    init(
        post: Post,
        vm: PostsViewModel
    ) {
        self._postsVM = StateObject(wrappedValue: vm)
        self.post = post
    }
    
    private func onAppear() {
        postsVM.onAppear(post.id)
    }
    
    private func onDisappear() {
        postsVM.onDisappear(post.id)
    }
    
    @MainActor
    private func tapAction(_ value: PostsViewModel.TappedPost) async {
//        navigationController.navigation.enabled = false
        await postsVM.tapPostAction(value)
    }
    
    
    var body: some View {
        CellView
            .onAppear(perform: onAppear)
            .onDisappear(perform: onDisappear)
    }
    
    @ViewBuilder
    private var CellView: some View {
        GeometryReader{
            let frame = $0.frame(in: .global).center
            let size = $0.size
            
            ImageContainer(size: size)
                .overlay {
                    BlurView(style: .light)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    let rect = CGRect(frame, size)
                    let value = PostsViewModel.TappedPost(self.post, self.image, rect)
                    Task {
                        await self.tapAction(value)
                    }
                    
                }
        }
        
    }
    
    @ViewBuilder
    private func ImageContainer(size: CGSize) -> some View {
        LazyImage(source: post.media.returnURL) {
            if let uiImage = $0.imageContainer?.image {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(size)
                    .clipped()
                    .opacity(opacity)
                    .onAppear {
                        self.image = uiImage
                    }
            } else {
                Color.primary.opacity(0.05)
            }
        }
        .pipeline(.shared)
        .processors([ImageProcessors.Resize(width: 100)])
        .priority(.veryHigh)
    }
    
    private var opacity: Double {
        return postsVM.selectedPost.post?.id == self.post.id && postsVM.selectedPost.didAppear ? 0 : 1
    }
}
