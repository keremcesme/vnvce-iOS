//
//  ProfileScrollView.swift
//  vnvce
//
//  Created by Kerem Cesme on 6.11.2022.
//

import SwiftUI
import PureSwiftUI
import Introspect

struct ProfileScrollView<Content: View>: View {
    @EnvironmentObject public var rootVM: RootViewModel
    
    @State private var progress: CGFloat = 0
    @State private var contentOffset: CGFloat = 0
    
    private var content: Content
    private var onRefresh: () async -> Void
    
    init(
        _ onRefresh: @escaping () async -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.content = content()
        self.onRefresh = onRefresh
    }
    
    private func scrollViewConnector(_ scrollView: UIScrollView) {
        self.rootVM.profileScrollView = scrollView
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing:0) {
                IndicatorView
                content
            }
            .frame(maxWidth: .infinity)
            .introspectScrollView(customize: scrollViewConnector)
            .offset(coordinateSpace: "SCROLL_PROFILE", offset: offsetTask)
        }
        .coordinateSpace(name: "SCROLL_PROFILE")
        .onChange(of: rootVM.profileIsRefreshing, perform: onChangeIsRefreshingTask)
//        .onChange(of: profileVM.isScrollEnabled, perform: profileVM.onChangeIsScrollEnabled)
    }
    
    @ViewBuilder
    private var IndicatorView: some View {
        ProgressView()
            .scaleEffect(rootVM.profilePullToRefreshIsEligible ? 1.5 : 0.001)
            .animation(.easeInOut(duration: 0.2), value: rootVM.profilePullToRefreshIsEligible)
            .overlay{
                Image("pointingDownEmoji")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 24, height: 24, alignment: .center)
                    .scaleEffect(progress)
                    .scaleEffect(rootVM.profilePullToRefreshIsEligible ? 0.001 : 1)
                    .opacity(rootVM.profilePullToRefreshIsEligible ? 0 : 1)
                    .animation(.easeInOut(duration: 0.25), value: rootVM.profilePullToRefreshIsEligible)
            }
            .frame(height: 50 * progress)
            .opacity(progress)
            .offset(y: yOffset)
    }
    
    private func offsetTask(offset: CGFloat) {
        // MARK: Storing Content Offset
        contentOffset = offset
        
        // MARK: Stopping The Progress When Its Elgible For Refresh
        if !rootVM.profilePullToRefreshIsEligible {
            var progress = offset / 100
            progress = (progress < 0 ? 0 : progress)
            progress = (progress > 1 ? 1 : progress)
            rootVM.profileScrollOffset = offset
            self.progress = progress
        }
        
        if rootVM.profilePullToRefreshIsEligible && !rootVM.profileIsRefreshing {
            rootVM.profileIsRefreshing = true
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
                    progress = 0
                    rootVM.profilePullToRefreshIsEligible = false
                    rootVM.profileIsRefreshing = false
                    rootVM.profileScrollOffset = 0
                }
            }
        }
    }
    
    private var yOffset: CGFloat {
        if rootVM.profilePullToRefreshIsEligible {
            let contentOffset = contentOffset
            if contentOffset < 0 {
                return 0
            } else {
                return -contentOffset
            }
        } else {
            let scrollOffset = rootVM.profileScrollOffset
            if scrollOffset < 0 {
                return 0
            } else {
                return -scrollOffset
            }
        }
    }
}
