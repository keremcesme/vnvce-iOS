//
//  PageScrollView.swift
//  vnvce
//
//  Created by Kerem Cesme on 12.11.2022.
//

import SwiftUI
import Introspect

struct PageViewProxy {
    
    var proxy: ScrollViewProxy
    
    func move(id: Int) {
        withAnimation(response: 0.3) {
            proxy.scrollTo(id)
        }
    }
    
}

struct PageView<Content: View>: View {
    @State private var privateOffset: CGFloat = 0
    @State private var privateSelection: Int = 0
    
    private var offset: Binding<CGFloat>?
    private var selection: Binding<Int>?
    
    private var content: (PageViewProxy) -> Content
    
    // No Bindings
    init(
        @ViewBuilder content: @escaping (PageViewProxy) -> Content
    ) {
        self.init(offset: nil, content: content)
    }
    
    // Only Offset Binding
    init(
        offset: Binding<CGFloat>,
        @ViewBuilder content: @escaping (PageViewProxy) -> Content
    ) {
        self.init(offset: .some(offset), selection: nil, content: content)
    }
    
    // Only Selection Binding
    init(
        selection: Binding<Int>,
        @ViewBuilder content: @escaping (PageViewProxy) -> Content
    ) {
        self.init(offset: nil, selection: .some(selection), content: content)
    }
    
    // All Bindings
    init(
        offset: Binding<CGFloat>,
        selection: Binding<Int>,
        @ViewBuilder content: @escaping (PageViewProxy) -> Content
    ) {
        self.init(offset: .some(offset), selection: .some(selection), content: content)
    }
    
    // PRIVATE
    private init(
        offset: Binding<CGFloat>? = nil,
        selection: Binding<Int>? = nil,
        @ViewBuilder content: @escaping (PageViewProxy) -> Content
    ) {
        self.content = content
        self.selection = selection
        self.offset = offset
    }
    
    internal var body: some View {
        _PageView(
            offset: offset ?? $privateOffset,
            selection: selection ?? $privateSelection,
            content: content
        )
    }
}

private struct _PageView<Content>: View where Content: View {
    @State private var contentWidth: CGFloat = 0
    
    @Binding private var offset: CGFloat
    @Binding private var selection: Int
    
    private var content: (PageViewProxy) -> Content
    
    init(
        offset: Binding<CGFloat>,
        selection: Binding<Int>,
        @ViewBuilder content: @escaping (PageViewProxy) -> Content
    ) {
        self._offset = offset
        self._selection = selection
        self.content = content
    }
    
    private let screenWidth = UIScreen.main.bounds.width
    
    private func offsetTask(_ value: CGFloat) {
        DispatchQueue.main.async {
            let absValue = abs(value)
//            let maxIndex = Int(contentWidth / screenWidth - 1)
//            let maxWidth = contentWidth - screenWidth
            
            self.offset = absValue
            self.selection = Int(round(absValue / screenWidth))
            
//            print("~~~~~~~~~~~~~~~~~~~")
//            print("PAGE COUNT: \(Int(contentWidth / screenWidth))")
//            print("MAX INDEX: \(maxIndex)")
//            print("MAX WIDTH: \(maxWidth)")
//            print("INDEX: \(absValue)")
//
//            print("\(Int(round(absValue / screenWidth)))")
            
        }
    }
    
    internal var body: some View {
        ScrollViewReader(content: ScrollContainer)
            .ignoresSafeArea()
    }
    
    @ViewBuilder
    private func ScrollContainer(_ proxy: ScrollViewProxy) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing:0) {
                content(PageViewProxy(proxy: proxy))
            }
            .introspectScrollView { scrollView in
                scrollView.isPagingEnabled = true
                scrollView.bounces = false
                scrollView.contentInsetAdjustmentBehavior = .never
            }
            .offsetX(offsetTask)
            .viewWidth($contentWidth)
        }
    }
}
