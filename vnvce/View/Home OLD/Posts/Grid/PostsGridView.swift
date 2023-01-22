//
//  PostsGridView.swift
//  vnvce
//
//  Created by Kerem Cesme on 19.09.2022.
//

import SwiftUI

struct PostsGridView: View {
    @EnvironmentObject var currentUserVM: CurrentUserViewModelOLD
    
    @StateObject private var postsVM: PostsViewModel
    
    var relationship: Relationship?
    
    init(vm: PostsViewModel, relationship: Relationship? = .friend(friendshipID: UUID())) {
        self._postsVM = StateObject(wrappedValue: vm)
        self.relationship = relationship
    }
    
    var body: some View {
        Root
    }
    
    @ViewBuilder
    private var Root: some View {
        if relationship?.raw == .friend {
//            if let postResults = postsVM.postResults {
//                if postResults.metadata.total != 0 {
//                    GridView(posts: postResults.items)
//                } else {
//                    NoPostView
//                }
//            }
            if postsVM.postResults.metadata.total != 0 {
                GridView(posts: postsVM.postResults.items)
            } else {
                NoPostView
            }
        } else if relationship == nil {
            RedactedPosts
        } else {
            Hidden
        }
        
//        if postsVM.postResults.items.count == 0 && postsVM.isRunning {
//            RedactedPosts
//        } else {
//            GridView
//        }
    }
    
    @ViewBuilder
    private func GridView(posts: [Post]) -> some View {
//        let columns = [
//            GridItem(.fixed(UIScreen.main.bounds.width / 2), spacing: 1),
//            GridItem(.fixed(UIScreen.main.bounds.width / 2), spacing: 1)
//        ]
        
        VStack(spacing: 20) {
            GridLayout(items: posts, id: \.id, spacing: 1) {
                PostsGridCellView(post: $0, vm: postsVM)
                    .task(if: $0 == posts.last, postsVM.loadNextPage)
            }
//            LazyVGrid(columns: columns, spacing: 1) {
//                ForEach(postsVM.postResults.items, id: \.id) {
//                    PostsGridCellView(post: $0, vm: postsVM)
//                        .id($0.id)
//                        .task(if: $0 == postsVM.postResults.items.last, postsVM.loadNextPage)
//                }
////                ForEach(Array(postsVM.postResults.items.enumerated()), id: \.element.id){ index, post in
////                    PostsGridCellView(post: $postsVM.postResults.items[index], vm: postsVM)
////                        .task(if: post == postsVM.postResults.items.last, postsVM.loadNextPage)
////                }
//            }
            Progress
        }
    }
    
    @ViewBuilder
    private var Progress: some View {
        if postsVM.postResults.items.count < postsVM.postResults.metadata.total && postsVM.isRunning {
            ProgressView()
        }
    }
    
    @ViewBuilder
    private var RedactedPosts: some View {
        GridLayout(items: 1..<9, id: \.self, spacing: 1) { _ in
            Color.primary.opacity(0.05)
        }
        .shimmering()
    }
    
    @ViewBuilder
    private var NoPostView: some View {
        VStack(spacing:10){
            Image(systemName: "square.grid.2x2")
                .foregroundColor(.primary)
                .font(.system(size: 50, weight: .ultraLight, design: .default))
            Text("No Posts Yet")
                .foregroundColor(.primary)
                .font(.system(size: 24, weight: .semibold, design: .default))
        }
        .frame(maxWidth: UIScreen.main.bounds.width, alignment: .center)
        .padding(.top, 50)
    }
    
    @ViewBuilder
    private var Hidden: some View {
        VStack(spacing:10){
            Image(systemName: "lock")
                .foregroundColor(.primary)
                .font(.system(size: 50, weight: .ultraLight, design: .default))
            Text("Add Friend For See")
                .foregroundColor(.primary)
                .font(.system(size: 24, weight: .semibold, design: .default))
        }
        .frame(maxWidth: UIScreen.main.bounds.width, alignment: .center)
        .padding(.top, 50)
    }
}
