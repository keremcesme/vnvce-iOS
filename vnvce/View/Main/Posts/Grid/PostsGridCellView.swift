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
    
    @State var selectedPost = PostsViewModel.SelectedPost()
    
    private var post: Post
    
    init(post: Post, vm: PostsViewModel) {
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
    private func tapAction(_ value: PostsViewModel.SelectPost) {
//        navigationController.navigation.enabled = false
        Task {
            await postsVM.tapPostAction(value)
        }
        
    }
    
    
    var body: some View {
        CellView
            .onAppear(perform: onAppear)
            .onDisappear(perform: onDisappear)
    }
    
    @ViewBuilder
    private var CellView: some View {
        GeometryReader{
            let frame = $0.frame(in: .global)
            let size = $0.size
            
            ImageContainer(size: size, frame: frame)
                .opacity(opacity())
        }
    }
    
    @ViewBuilder
    private func ImageContainer(size: CGSize, frame: CGRect) -> some View {
        LazyImage(url: post.media.returnURL) {
            if let uiImage = $0.imageContainer?.image {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(size)
                    .clipped()
                    .overlay {
                        BlurView(style: .light)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        let value = PostsViewModel.SelectPost(post: post,
                                                              previewImage: uiImage,
                                                              frame: frame,
                                                              size: size)
                        self.tapAction(value)
                    }
                    .onAppear {
                        guard let index = postsVM.postResults.items.firstIndex(where: {$0 == post}) else {
                            return
                        }
                        
                        postsVM.postResults.items[index].previewImage = CodableImage(image: uiImage)
                    }
            } else {
                Color.primary.opacity(0.05)
                    .shimmering()
            }
        }
        .animation(nil)
        .pipeline(.shared)
        .processors([ImageProcessors.Resize(width: 100)])
        .priority(.veryHigh)
    }
    
    private func opacity() -> Double {
        return postsVM.selectedPost.post?.id == self.post.id && postsVM.selectedPost.didAppear ? 0 : 1
    }
}
