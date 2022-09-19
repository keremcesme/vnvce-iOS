//
//  PostsView.swift
//  vnvce
//
//  Created by Kerem Cesme on 19.09.2022.
//

import SwiftUI

struct PostsView: View {
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
            PostsGridView(vm: postsVM)
        }
    }
    
    @ViewBuilder
    var RedactedPosts: some View {
        GridLayout(items: 1..<9, id: \.self, spacing: 1) { _ in
            Color.primary.opacity(0.05)
        }
        .shimmering()
    }
}
