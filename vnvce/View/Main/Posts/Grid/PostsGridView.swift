//
//  PostsGridView.swift
//  vnvce
//
//  Created by Kerem Cesme on 19.09.2022.
//

import SwiftUI

struct PostsGridView: View {
    @EnvironmentObject var currentUserVM: CurrentUserViewModel
    
    @StateObject private var postsVM: PostsViewModel
    
    init(vm: PostsViewModel) {
        self._postsVM = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        Root
    }
    
    @ViewBuilder
    private var Root: some View {
        if postsVM.postResults.items.count == 0 && postsVM.isRunning {
            RedactedPosts
        } else {
            GridView
        }
    }
    
    @ViewBuilder
    private var GridView: some View {
//        let columns = [
//            GridItem(.fixed(UIScreen.main.bounds.width / 2), spacing: 1),
//            GridItem(.fixed(UIScreen.main.bounds.width / 2), spacing: 1)
//        ]
        
        VStack(spacing: 20) {
            GridLayout(items: postsVM.postResults.items, id: \.id, spacing: 1) {
                PostsGridCellView(post: $0, vm: postsVM)
                    .task(if: $0 == postsVM.postResults.items.last, postsVM.loadNextPage)
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
}
