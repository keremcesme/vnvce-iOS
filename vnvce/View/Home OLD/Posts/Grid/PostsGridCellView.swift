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
//        postsVM.onAppear(post.id)
    }
    
    private func onDisappear() {
//        postsVM.onDisappear(post.id)
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
                        if let second = post.displayTime?.second {
                            if second < 3 {
                                BlurView(style: .light)
                            }
                        } else {
                            BlurView(style: .light)
                        }
                    }
                    .overlay(alignment: .bottomTrailing, {
                        Group {
                            if let displayTime = post.displayTime, displayTime.second >= 3.0 {
                                Image(uiImage: timerImage())
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 16, height: 16)
//                                HStack(spacing:3) {
//                                    Text("🥳")
//                                        .font(.system(size: 11))
//                                    Text(String(format: "%0.1fs", displayTime.second))
//                                        .font(.system(size: 14, weight: .semibold, design: .default))
//                                }
                            }
                        }
                        .foregroundColor(.white)
                        .shadow(radius: 4)
                        .padding(5)
//                        .padding(.horizontal, 7.5)
//                        .padding(.bottom, 3)
                    })
                    .contentShape(Rectangle())
                    .onTapGesture {
                        let value = PostsViewModel.SelectPost(post: post,
                                                              previewImage: uiImage,
                                                              frame: frame,
                                                              size: size)
                        navigationController.navigation.enabled = false
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
    
    private func timerImage() -> UIImage {
        switch post.displayTime!.second {
        case (0..<3):
            return UIImage()
        case (3..<7):
            return LikeEmojiLevel.level1.image
        case (7..<11):
            return LikeEmojiLevel.level2.image
        case (11..<15):
            return LikeEmojiLevel.level3.image
        case (15..<19):
            return LikeEmojiLevel.level4.image
        case (19..<23):
            return LikeEmojiLevel.level5.image
        case (23..<27):
            return LikeEmojiLevel.level6.image
        default:
            return LikeEmojiLevel.level7.image
        }
    }
}
