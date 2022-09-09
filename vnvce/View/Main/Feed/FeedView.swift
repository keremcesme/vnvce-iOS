//
//  FeedView.swift
//  vnvce
//
//  Created by Kerem Cesme on 7.09.2022.
//

import SwiftUI

struct FeedView: View {
    @EnvironmentObject private var searchVM: SearchViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                CurrentUserBackground()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar(ToolBar)
        }
    }
}

extension FeedView {
    
    @ToolbarContentBuilder
    private var ToolBar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) { vnvceLabel }
        ToolbarItem(placement: .navigationBarTrailing) { SearchButton }
    }
    
    @ViewBuilder
    private var vnvceLabel: some View {
        Text("vnvce".lowercased())
            .font(.title.bold())
            .foregroundColor(.primary)
    }
    
    @ViewBuilder
    private var SearchButton: some View {
        Button {
            DispatchQueue.main.async {
                searchVM.show = true
            }
        } label: {
            Image(systemName: "magnifyingglass.circle.fill")
                .font(.title2)
                .foregroundColor(.primary)
        }
        .buttonStyle(.plain)
    }
}

