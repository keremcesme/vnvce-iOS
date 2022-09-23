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
    @StateObject var scrollDelegate: PostScrollViewModel
    
    var content: Content
    
    var onRefresh: () async -> Void
    
    init(
        scrollDelegate: PostScrollViewModel,
        @ViewBuilder content: @escaping () -> Content,
        onRefresh: @escaping () async -> Void
    ) {
        self._scrollDelegate = StateObject(wrappedValue: scrollDelegate)
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
            .introspectScrollView(customize: scrollDelegate.scrollViewConnector)
            .offset(coordinateSpace: "SCROLL", offset: offsetTask)
        }
        .coordinateSpace(name: "SCROLL")
        .onChange(of: scrollDelegate.isRefreshing, perform: onChangeIsRefreshingTask)
        .onChange(of: scrollDelegate.isScrollEnabled, perform: scrollDelegate.onChangeIsScrollEnabled)
    }
    
    @ViewBuilder
    private var IndicatorView: some View {
        ProgressView()
            .scaleEffect(scrollDelegate.isEligible ? 1.5 : 0.001)
            .animation(.easeInOut(duration: 0.2), value: scrollDelegate.isEligible)
            .overlay{
                Image("pointingDownEmoji")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 24, height: 24, alignment: .center)
                    .scaleEffect(scrollDelegate.progress)
                    .scaleEffect(scrollDelegate.isEligible ? 0.001 : 1)
                    .opacity(scrollDelegate.isEligible ? 0 : 1)
                    .animation(.easeInOut(duration: 0.25), value: scrollDelegate.isEligible)
            }
            .frame(height: 50 * scrollDelegate.progress)
            .opacity(scrollDelegate.progress)
            .offset(y: yOffset)
    }
    
    private func offsetTask(offset: CGFloat) {
        // MARK: Storing Content Offset
        scrollDelegate.contentOffset = offset
//        if let action = self.offset {
//            action(scrollDelegate.scrollOffset)
//        }
        
        // MARK: Stopping The Progress When Its Elgible For Refresh
        if !scrollDelegate.isEligible {
            var progress = offset / 100
            progress = (progress < 0 ? 0 : progress)
            progress = (progress > 1 ? 1 : progress)
            scrollDelegate.scrollOffset.y = offset
            scrollDelegate.progress = progress
        }
        
        if scrollDelegate.isEligible && !scrollDelegate.isRefreshing {
            scrollDelegate.isRefreshing = true
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
                    scrollDelegate.progress = 0
                    scrollDelegate.isEligible = false
                    scrollDelegate.isRefreshing = false
                    scrollDelegate.scrollOffset.y = 0
                }
            }
        }
    }
    
    private var yOffset: CGFloat {
        if scrollDelegate.isEligible {
            let contentOffset = scrollDelegate.contentOffset
            if contentOffset < 0 {
                return 0
            } else {
                return -contentOffset
            }
        } else {
            let scrollOffset = scrollDelegate.scrollOffset.y
            if scrollOffset < 0 {
                return 0
            } else {
                return -scrollOffset
            }
        }
    }
}

