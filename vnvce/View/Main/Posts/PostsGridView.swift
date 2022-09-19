//
//  PostsGridView.swift
//  vnvce
//
//  Created by Kerem Cesme on 19.09.2022.
//

import SwiftUI

struct PostsGridView: View {
    @StateObject private var postsVM: PostsViewModel
    
    init(vm: PostsViewModel) {
        self._postsVM = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        VStack(spacing: 20){
            GridLayout(items: postsVM.postResults.items, id: \.id, spacing: 1) {
                PostsGridCellView(post: $0, vm: postsVM)
                    .task(if: $0 == postsVM.postResults.items.last, postsVM.loadNextPage)
            }
            Progress
        }
    }
    
    @ViewBuilder
    private var Progress: some View {
        if postsVM.postResults.items.count < postsVM.postResults.metadata.total && postsVM.isRunning {
            ProgressView()
        }
    }
    
}
