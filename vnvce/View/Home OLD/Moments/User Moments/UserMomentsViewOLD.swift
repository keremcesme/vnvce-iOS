//
//  MomentView.swift
//  vnvce
//
//  Created by Kerem Cesme on 31.10.2022.
//

import SwiftUI
import SwiftUIX
import PureSwiftUI
import Nuke
import NukeUI
import Introspect

struct UserMomentsRootView: View {
    @StateObject private var momentsVM: UserMomentsViewModelOLD
    @StateObject private var momentsVM2: MomentsViewModelOLD
    
    init(_ momentsVM: UserMomentsViewModelOLD, momentsVM2: MomentsViewModelOLD) {
        self._momentsVM = StateObject(wrappedValue: momentsVM)
        self._momentsVM2 = StateObject(wrappedValue: momentsVM2)
    }
    
    var body: some View {
        ZStack {
            EmptyView()
            if momentsVM.momentsViewWillAppear {
                EmptyView()
                if momentsVM.openMomentsView {
                    Color.black.opacity(momentsVM.onDragging ? 0.2 : 1).ignoresSafeArea()
                }
                UserMomentsViewOLD(momentsVM)
            }
            
            
        }
    }
}

struct UserMomentsViewOLD: View {
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject public var momentsVM: UserMomentsViewModelOLD
    
    init(_ momentsVM: UserMomentsViewModelOLD) {
        self._momentsVM = StateObject(wrappedValue: momentsVM)
    }
    
    private var momentsViewScaleEffect: CGFloat {
        if momentsVM.openMomentsView {
            if momentsVM.offset.width < 0 {
                return 1.0
            } else {
                let max = UIScreen.main.bounds.width / 2
                let currentAmount = abs(momentsVM.offset.width)
                let percentage = currentAmount / max
                return 1.0 - min(percentage, 0.15)
            }
        } else {
            return (UIScreen.main.bounds.width / 3) / UIScreen.main.bounds.width
        }
    }
    
    var body: some View {
        MomentsView
            .overlay(PreviewView)
            .cornerRadius(UIDevice.current.screenCornerRadius, style: .continuous)
            .scaleEffect(momentsViewScaleEffect)
            .mask(ViewMask)
            .offset(self.momentsVM.offset)
            .offsetToPositionIf(!momentsVM.openMomentsView, momentsVM.selectedMomentDayCellFrame.center)
            .ignoresSafeArea()
    }
    
    @ViewBuilder
    private var MomentsView: some View {
        GeometryReader{
            let proxy = $0
            let size = proxy.size
            ZStack(alignment: .top){
                Color.black.frame(size)
                PaginationView(axis: .vertical, showsIndicators: false) {
                    ForEach(Array(momentsVM.momentsMain.enumerated()), id: \.element.id) { inx, moments in
                        UserMomentsDayView(
                            moments: $momentsVM.momentsMain[inx],
                            index: inx,
                            proxy: proxy,
                            momentsVM: momentsVM)
                    }
                }
                .initialPageIndex(momentsVM.currentIndex)
                .currentPageIndex($momentsVM.currentIndex)
                .interPageSpacing(15)
                .scrollDisabled(momentsVM.onDragging)
                .opacity(momentsVM.openMomentsView ? 1 : 0.0001)
                .onChange(of: momentsVM.currentIndex) { newIndex in
                    Task.detached(priority: .high) {
                        await self.momentsVM.downloadMoreImages2(index: newIndex)
                    }
                }
            }
        }
        .frame(UIScreen.main.bounds.size)
    }
    
    @ViewBuilder
    var ViewMask: some View {
        RoundedRectangle(momentsVM.openMomentsView ? UIDevice.current.screenCornerRadius : 0, style: .continuous)
            .frame(momentsVM.openMomentsView ? UIScreen.main.bounds.size : momentsVM.selectedMomentDayCellSize)
            .ignoresSafeArea()
    }
}
