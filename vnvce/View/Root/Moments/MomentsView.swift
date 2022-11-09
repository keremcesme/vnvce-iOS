//
//  MomentsView.swift
//  vnvce
//
//  Created by Kerem Cesme on 8.11.2022.
//

import SwiftUI
import SwiftUIX
import PureSwiftUI

struct MomentsRootView: View {
    @StateObject private var momentsVM: MomentsViewModel
    
    init(_ vm: MomentsViewModel) {
        self._momentsVM = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        ZStack {
            EmptyView()
            if momentsVM.viewWillAppear {
                if momentsVM.show {
//                    Color.black.opacity(1).ignoresSafeArea()
                }
                MomentsView(momentsVM)
            }
        }
    }
}

struct MomentsView: View {
    @StateObject public var momentsVM: MomentsViewModel
    
    init(_ vm: MomentsViewModel) {
        self._momentsVM = StateObject(wrappedValue: vm)
    }
    
    private func backgroundOpacity() -> CGFloat {
        if momentsVM.show {
            if momentsVM.onDragging {
                let width = momentsVM.viewOffset.width / (UIScreen.main.bounds.width / 2)
                let height = momentsVM.viewOffset.height / (UIScreen.main.bounds.height / 2)
                return 1.0 - width - height
            } else {
                return 1
            }
        } else {
            return 0.00001
        }
    }
    
    var body: some View {
        ZStack {
            Color.black
                .opacity(backgroundOpacity())
                .ignoresSafeArea()
            
            MomentsDayViews
            PreviewView
        }
        
        
    }
    
    @ViewBuilder
    private var MomentsDayViews: some View {
        PageView(selection: $momentsVM.pageIndex,
                 id: momentsVM.moments.count - 1,
                 scrollViewConnector: momentsVM.scrollViewConnector,
                 content: PageItem)
    }
    
    @ViewBuilder
    private func PageItem(_ proxy: GeometryProxy) -> some View {
        ForEach(Array(momentsVM.moments.enumerated()), id: \.element.id) { index, item in
            MomentsDayView(proxy: proxy, index: index, moments: $momentsVM.moments[index], vm: momentsVM)
        }
    }
    
    
    
}
