//
//  ScrollViewRefreshable.swift
//  vnvce
//
//  Created by Kerem Cesme on 9.09.2022.
//

import SwiftUI
import PureSwiftUI

// MARK: Custom View Modifier
struct ScrollViewRefreshable<Content: View>: View {
    typealias Action = (CGPoint) -> Void
    
    @StateObject var scrollDelegate: ScrollViewModel
    
    var content: Content
    var showsIndicator: Bool
    var topPadding: CGFloat
    
    let offset: Action?
    
    var onRefresh: () async -> Void
    
    init(
        scrollDelegate: ScrollViewModel,
        showsIndicator: Bool = true,
        topPadding: CGFloat = 0,
        offset: Action? = nil,
        @ViewBuilder content: @escaping () -> Content,
        onRefresh: @escaping () async -> Void
    ) {
        self.showsIndicator = showsIndicator
        self.topPadding = topPadding
        self.content = content()
        self.offset = offset
        self.onRefresh = onRefresh
        self._scrollDelegate = StateObject(wrappedValue: scrollDelegate)
    }
    
    
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: showsIndicator) {
            VStack(spacing:0) {
                IndicatorView
                content
            }
            .padding(.top, topPadding)
            .offset(coordinateSpace: "SCROLL", offset: offsetTask)
        }
        .coordinateSpace(name: "SCROLL")
        .onAppear(perform: scrollDelegate.addGesture)
        .onDisappear(perform: scrollDelegate.removeGesture)
        .onChange(of: scrollDelegate.isRefreshing, perform: onChangeIsRefreshingTask)
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
                    .scaleEffect(scrollDelegate.progress > 0.001 ? scrollDelegate.progress : 0.001)
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
        if let action = self.offset {
            action(scrollDelegate.scrollOffset)
        }
        
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

// MARK: For Simultanous Pan Gesture
class ScrollViewModel: NSObject, ObservableObject, UIGestureRecognizerDelegate {
    // MARK: Properties
    @Published var isEligible: Bool = false
    @Published var isRefreshing: Bool = false
    
    // MARK: Ofsets and Progress
    @Published var scrollOffset: CGPoint = .zero
    @Published var contentOffset: CGFloat = 0
    @Published var progress: CGFloat = 0
    
    // Adding Pan Gesture To UI Main Application Window
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: Adding Gesture
    func addGesture() {
        let pangGesture = UIPanGestureRecognizer(target: self, action: #selector(onGestureChange))
        pangGesture.delegate = self
        rootController().view.addGestureRecognizer(pangGesture)
    }
    
    // MARK: Removing When Leaving The View
    func removeGesture() {
        rootController().view.gestureRecognizers?.removeAll()
    }
    
    // MARK: Finding Root Controller
    func rootController() -> UIViewController {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = screen.windows.first?.rootViewController
        else {
            return .init()
        }
        
        return root
    }
    
    @objc
    func onGestureChange(gesture: UIPanGestureRecognizer) {
        if gesture.state == .cancelled || gesture.state == .ended {
//            print("User Released Touch")
            if !isRefreshing {
                if scrollOffset.y > 100 {
                    isEligible = true
                } else {
                    isEligible = false
                }
            }
        }
    }
}

// MARK: Offset Modifier
extension View {
    @ViewBuilder
    func offset(coordinateSpace: String, offset: @escaping (CGFloat) -> Void) -> some View {
        self
            .overlay {
                GeometryReader{ proxy in
                    let minY = proxy.frame(in: .named(coordinateSpace)).minY
                    
                    Color.clear
                        .preference(key: ScrollOffsetKey.self, value: minY)
                        .onPreferenceChange(ScrollOffsetKey.self, perform: offset)
                }
            }
    }
}

// MARK: Offset Preference Key
struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}



