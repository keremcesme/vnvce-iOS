//
//  PostsScrollView.swift
//  vnvce
//
//  Created by Kerem Cesme on 22.09.2022.
//

import SwiftUI
import PureSwiftUI
import Introspect


struct PostsScrollView<Content: View>: View {
    
    @StateObject private var scrollDelegate: PostsScrollViewModel
    
    var content: Content
    
    init(
        _ scrollDelegate: PostsScrollViewModel,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._scrollDelegate = StateObject(wrappedValue: scrollDelegate)
        self.content = content()
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing:30) {
                content
            }
            .padding(.top, UIDevice.current.statusAndNavigationBarHeight)
            .padding(.bottom, UIScreen.main.bounds.height / 2)
            .offset(coordinateSpace: "SCROLL", offset: offsetTask)
//            .introspectScrollView{
////                $0.isScrollEnabled = !scrollDelegate.scrollIsDisabled
////                if scrollDelegate.scrollIsDisabled {
////
////                    print("here")
////                } else {
////                    $0.isScrollEnabled = true
////                    print("here2")
////                }
//            }
        }
        .coordinateSpace(name: "SCROLL")
        
    }
    
    private func offsetTask(offset: CGFloat) {
        // MARK: Storing Content Offset
        scrollDelegate.scrollOffset = offset
    }
    
}
