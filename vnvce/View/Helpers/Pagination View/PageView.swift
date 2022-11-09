//
//  VerticalPaginationView.swift
//  vnvce
//
//  Created by Kerem Cesme on 8.11.2022.
//

import SwiftUI
import PureSwiftUI
import Introspect

struct PageView<Content, ID, SelectionValue>: View
where Content: View,
      ID: Hashable,
      SelectionValue: Hashable {
    
    private let axes: Axis.Set
    
    private var id: ID
    private var content: (GeometryProxy) -> Content
    
    private var scrollViewConnector: (UIScrollView) -> ()
    
    @Binding private var selection: SelectionValue
    
    init(
        axes: Axis.Set = .vertical,
        selection: Binding<SelectionValue>,
        id: ID,
        scrollViewConnector: @escaping (UIScrollView) -> Void,
        @ViewBuilder content: @escaping (GeometryProxy) -> Content
    ) {
        self.axes = axes
        self._selection = selection
        self.id = id
        self.content = content
        self.scrollViewConnector = scrollViewConnector
    }
    
    var body: some View {
        ScrollView(.init()){
            GeometryReader(content: PageView)
                .ignoresSafeArea()
        }
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    private func PageView(_ proxy: GeometryProxy) -> some View {
        let size = proxy.size
        TabView(selection: $selection) {
            content(proxy)
                .frame(width: size.width, height: size.height)
                .rotationEffect(contentRotation)
                .introspectScrollView(customize: scrollViewConnector)
        }
        .frame(returnSize(size))
        .rotationEffect(pageRotationAngle, anchor: pageRotationAnchor)
        .offset(x: pageOffset(size.width))
        .id(id)
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
    
    private var contentRotation: Angle {
        if self.axes == .vertical {
            return .degrees(-90)
        } else {
            return .degrees(0)
        }
    }
    
    private var pageRotationAngle: Angle {
        if self.axes == .vertical {
            return .degrees(90)
        } else {
            return .degrees(0)
        }
    }
    
    private var pageRotationAnchor: UnitPoint {
        if self.axes == .vertical {
            return .topLeading
        } else {
            return .center
        }
    }
    
    private func returnSize(_ size: CGSize) -> CGSize {
        if self.axes == .vertical {
            return CGSize(width: size.height, height: size.width)
        } else {
            return CGSize(width: size.width, height: size.height)
        }
    }
    
    private func pageOffset(_ width: CGFloat) -> CGFloat {
        if self.axes == .vertical {
            return width
        } else {
            return 0
        }
    }
}
