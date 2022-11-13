//
//  RefreshableScrollView.swift
//  vnvce
//
//  Created by Kerem Cesme on 13.11.2022.
//

import SwiftUI

class RefreshableScrollViewModel: NSObject, ObservableObject, UIGestureRecognizerDelegate {
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
    public func addGesture() {
        deleteGesture()
        let pangGesture = UIPanGestureRecognizer(target: self, action: #selector(onGestureChange))
        pangGesture.delegate = self
        rootController().view.addGestureRecognizer(pangGesture)
    }
    
    public func deleteGesture() {
        rootController().view.gestureRecognizers?.removeAll()
    }
    
    // MARK: Finding Root Controller
    private func rootController() -> UIViewController {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = screen.windows.first?.rootViewController
        else {
            return .init()
        }
        
        return root
    }
    
    @objc
    private func onGestureChange(gesture: UIPanGestureRecognizer) {
        if gesture.state == .cancelled || gesture.state == .ended {
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

private struct _RefreshableScrollView<Content: View>: View {
    @StateObject private var vm: RefreshableScrollViewModel
    
    private var topPadding: CGFloat
    
    private var axes: Axis.Set
    private var showsIndicator: Bool
    private var content: Content
    
    private var action: () async -> Void
    
    fileprivate init(
        _ scrollView: ScrollView<Content>,
        topPadding: CGFloat,
        delegate: RefreshableScrollViewModel,
        action: @escaping () async -> Void
    ) {
        self.topPadding = topPadding
        self.axes = scrollView.axes
        self.showsIndicator = scrollView.showsIndicators
        self.content = scrollView.content
        self.action = action
        self._vm = StateObject(wrappedValue: delegate)
    }
    
    var body: some View {
        ScrollView(axes, showsIndicators: showsIndicator) {
            VStack(spacing:0) {
                IndicatorView
                content
            }
            .padding(.top, topPadding)
            .scrollOffset(coordinateSpace: "SCROLL", offset: offsetTask)
        }
        .coordinateSpace(name: "SCROLL")
        .onChange(of: vm.isRefreshing, perform: onChangeIsRefreshingTask)
    }
    
    @ViewBuilder
    private var IndicatorView: some View {
        ProgressView()
            .scaleEffect(vm.isEligible ? 1.5 : 0.001)
            .animation(.easeInOut(duration: 0.2), value: vm.isEligible)
            .overlay{
                Image("pointingDownEmoji")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 24, height: 24, alignment: .center)
                    .scaleEffect(vm.progress > 0.001 ? vm.progress : 0.001)
                    .scaleEffect(vm.isEligible ? 0.001 : 1)
                    .opacity(vm.isEligible ? 0 : 1)
                    .animation(.easeInOut(duration: 0.25), value: vm.isEligible)
            }
            .frame(height: 50 * vm.progress)
            .opacity(vm.progress)
            .offset(y: yOffset)
    }
    
    private func offsetTask(offset: CGFloat) {
        // MARK: Storing Content Offset
        vm.contentOffset = offset
        
        // MARK: Stopping The Progress When Its Elgible For Refresh
        if !vm.isEligible {
            var progress = offset / 100
            progress = (progress < 0 ? 0 : progress)
            progress = (progress > 1 ? 1 : progress)
            vm.scrollOffset.y = offset
            vm.progress = progress
        }
        
        if vm.isEligible && !vm.isRefreshing {
            vm.isRefreshing = true
            // MARK: Haptic Feedback
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
    
    private func onChangeIsRefreshingTask(newValue: Bool) {
        // MARK: Calling Async Method
        if newValue {
            Task {
                await action()
                try? await Task.sleep(seconds: 0.5)
                withAnimation(.easeInOut(duration: 0.25)) {
                    vm.progress = 0
                    vm.isEligible = false
                    vm.isRefreshing = false
                    vm.scrollOffset.y = 0
                }
            }
        }
    }
    
    private var yOffset: CGFloat {
        if vm.isEligible {
            let contentOffset = vm.contentOffset
            if contentOffset < 0 {
                return 0
            } else {
                return -contentOffset
            }
        } else {
            let scrollOffset = vm.scrollOffset.y
            if scrollOffset < 0 {
                return 0
            } else {
                return -scrollOffset
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

// MARK: Offset Modifier
fileprivate extension View {
    @ViewBuilder
    func scrollOffset(coordinateSpace: String, offset: @escaping (CGFloat) -> Void) -> some View {
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

extension ScrollView {
    
    @ViewBuilder
    func refreshable(
        topPadding: CGFloat = 0,
        delegate: RefreshableScrollViewModel,
        _ action: @escaping () async -> Void
    ) -> some View {
        _RefreshableScrollView(self, topPadding: topPadding, delegate: delegate, action: action)
    }
    
}
