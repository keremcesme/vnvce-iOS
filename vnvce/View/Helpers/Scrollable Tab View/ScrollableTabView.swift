//
//  ScrollableTabView.swift
//  vnvce
//
//  Created by Kerem Cesme on 6.11.2022.
//

import SwiftUI

struct ScrollableTabView<Content: View>: UIViewRepresentable {
    private var content: Content
    private var rect: CGRect
    private var tabs: [Any]
    
    @Binding private var offset: CGFloat
    @Binding private var location: CGPoint
    
    private let scrollView = UIScrollView()
    
    init(
        tabs: [Any],
        rect: CGRect,
        offset: Binding<CGFloat>,
        location: Binding<CGPoint>,
        @ViewBuilder content: () -> Content
    ) {
        self.tabs = tabs
        self.rect = rect
        self._offset = offset
        self._location = location
        self.content = content()
    }
    
    internal func makeUIView(context: Context) -> UIScrollView {
        let tabCount: CGFloat = CGFloat(self.tabs.count)
        
//        let gesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.onGestureChange))
//        scrollView.addGestureRecognizer(gesture)
        
        setUpScrollView()
        
        
        scrollView.contentSize = CGSize(width: self.rect.width * tabCount, height: self.rect.height)
        
        scrollView.addSubview(extractView())
        
        
        
        scrollView.delegate = context.coordinator
        
        return scrollView
    }
    
    internal func updateUIView(_ uiView: UIScrollView, context: Context) {}
    
    internal func makeCoordinator() -> Coordinator {
        return ScrollableTabView.Coordinator(self)
    }
    
    private func setUpScrollView() {
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
    }
    
    private func extractView() -> UIView {
        let tabCount: CGFloat = CGFloat(self.tabs.count)
        let controller = UIHostingController(rootView: content)
        controller.view.frame = CGRect(
            x: 0,
            y: 0,
            width: self.rect.width * tabCount,
            height: self.rect.height)
        
        return controller.view!
    }
    
    internal class Coordinator: NSObject, UIScrollViewDelegate, UIGestureRecognizerDelegate {
        private var parent: ScrollableTabView
        
        init(_ parent: ScrollableTabView) {
            self.parent = parent
        }
        
        internal func scrollViewDidScroll(_ scrollView: UIScrollView) {
            parent.offset = scrollView.contentOffset.x
            parent.location =  scrollView.panGestureRecognizer.location(in: scrollView)
        }
        
        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            print("Will Begin Dragging")
//            let location = scrollView.panGestureRecognizer.location(in: scrollView)
//            parent.scrollView.isScrollEnabled = false
            
        }
        
        func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
            print("Will Begin Decelerating")
        }
        
        @objc
        func onGestureChange(gesture: UIPanGestureRecognizer) {
            let location = gesture.location(in: gesture.view)
            print(location)
        }
    }
}
