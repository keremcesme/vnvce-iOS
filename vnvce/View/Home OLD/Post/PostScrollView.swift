//
//  PostScrollView.swift
//  vnvce
//
//  Created by Kerem Cesme on 19.09.2022.
//

import SwiftUI
import PureSwiftUI
import Introspect

// MARK: Custom View Modifier
struct PostScrollView<Content: View>: View {
    @StateObject var postVM: PostViewModel
    
    var content: Content
    
    var onRefresh: () async -> Void
    
    init(
        _ postVM: PostViewModel,
        @ViewBuilder content: @escaping () -> Content,
        onRefresh: @escaping () async -> Void
    ) {
        self._postVM = StateObject(wrappedValue: postVM)
        self.content = content()
        self.onRefresh = onRefresh
    }
    
    var body: some View {
        
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing:0) {
                IndicatorView
                content
            }
            .padding(.top, UIDevice.current.statusAndNavigationBarHeight)
            .introspectScrollView(customize: postVM.scrollViewConnector)
            .offset(coordinateSpace: "SCROLL", offset: offsetTask)
        }
        .coordinateSpace(name: "SCROLL")
        .onChange(of: postVM.isRefreshing, perform: onChangeIsRefreshingTask)
        .onChange(of: postVM.isScrollEnabled, perform: postVM.onChangeIsScrollEnabled)
    }
    
    @ViewBuilder
    private var IndicatorView: some View {
        ProgressView()
            .scaleEffect(postVM.isEligible ? 1.5 : 0.001)
            .animation(.easeInOut(duration: 0.2), value: postVM.isEligible)
            .overlay{
                Image("pointingDownEmoji")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 24, height: 24, alignment: .center)
                    .scaleEffect(postVM.progress)
                    .scaleEffect(postVM.isEligible ? 0.001 : 1)
                    .opacity(postVM.isEligible ? 0 : 1)
                    .animation(.easeInOut(duration: 0.25), value: postVM.isEligible)
            }
            .frame(height: 50 * postVM.progress)
            .opacity(postVM.progress)
            .offset(y: yOffset)
    }
    
    private func offsetTask(offset: CGFloat) {
        // MARK: Storing Content Offset
        postVM.contentOffset = offset
//        if let action = self.offset {
//            action(scrollDelegate.scrollOffset)
//        }
        
        // MARK: Stopping The Progress When Its Elgible For Refresh
        if !postVM.isEligible {
            var progress = offset / 100
            progress = (progress < 0 ? 0 : progress)
            progress = (progress > 1 ? 1 : progress)
            postVM.scrollOffset.y = offset
            postVM.progress = progress
        }
        
        if postVM.isEligible && !postVM.isRefreshing {
            postVM.isRefreshing = true
            // MARK: Haptic Feedback
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
    
    private func onChangeIsRefreshingTask(newValue: Bool) {
        // MARK: Calling Async Method
        if newValue {
            Task {
                await onRefresh()
                try? await Task.sleep(seconds: 0.5)
                withAnimation(.easeInOut(duration: 0.25)) {
                    postVM.progress = 0
                    postVM.isEligible = false
                    postVM.isRefreshing = false
                    postVM.scrollOffset.y = 0
                }
            }
        }
    }
    
    private var yOffset: CGFloat {
        if postVM.isEligible {
            let contentOffset = postVM.contentOffset
            if contentOffset < 0 {
                return 0
            } else {
                return -contentOffset
            }
        } else {
            let scrollOffset = postVM.scrollOffset.y
            if scrollOffset < 0 {
                return 0
            } else {
                return -scrollOffset
            }
        }
    }
}

