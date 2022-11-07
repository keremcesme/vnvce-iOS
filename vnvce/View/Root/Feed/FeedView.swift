//
//  FeedView.swift
//  vnvce
//
//  Created by Kerem Cesme on 7.09.2022.
//

import SwiftUI
import SwiftUIX
import PureSwiftUI
import Introspect

struct FeedView: View {
    @EnvironmentObject private var searchVM: SearchViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                CurrentUserBackground()
                MomentsView
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar(ToolBar)
        }
    }
}

extension FeedView {
    
    @ViewBuilder
    private var MomentsView: some View {
        PaginationView(axis: .vertical, showsIndicators: false) {
            ForEach(0..<30, id: \.self) { index in
                FeedMomentView()
//                RoundedRectangle(cornerRadius: 12)
//                    .foregroundColor(.primary).opacity(0.1)
            }
        }
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    private var MomentsView2: some View {
        HStack(spacing:0) {
            GeometryReader{
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing:15) {
                            ForEach((0...30), id: \.self){ item in
                                Button {
                                    withAnimation {
                                        proxy.scrollTo("\(item)", anchor: .top)
                                    }
                                } label: {
                                    RoundedRectangle(10, style: .continuous)
                                        .foregroundColor(.primary)
                                        .frame(width: 30, height: 30)
                                        .overlay {
                                            Text("\(item)")
                                        }
                                        .opacity(0.1)
                                }
                                .buttonStyle(.plain)
                                .id("\(item)")
                            }
                        }
                        .introspectScrollView { scrollView in
                            scrollView.setContentOffset(.zero, animated: true)
                        }
                    }
                }
                .frame(maxWidth: $0.size.width)
            }
            .frame(maxWidth: 60, maxHeight: .infinity)
            
            GeometryReader {
                let size = $0.size
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing:15) {
                            ForEach((0...30), id: \.self){ item in
                                Rectangle()
                                    .foregroundColor(.primary)
                                    .frame(width: size.width, height: size.width * 5 / 3)
                                    .opacity(0.1)
                            }
                        }
                    }
                }
                .frame(maxWidth: size.width)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
           
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
