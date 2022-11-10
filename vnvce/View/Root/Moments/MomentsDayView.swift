//
//  MomentsDayView.swift
//  vnvce
//
//  Created by Kerem Cesme on 9.11.2022.
//

import SwiftUI
import SwiftUIX
import PureSwiftUI

struct MomentsDayView: View {
    @StateObject public var momentsVM: MomentsViewModel
    
    private var proxy: GeometryProxy
    private var index: Int
    
    @Binding private var moments: Moments
    
    init(
        proxy: GeometryProxy,
        index: Int,
        moments: Binding<Moments>,
        vm: MomentsViewModel
    ) {
        self.proxy = proxy
        self.index = index
        self._moments = moments
        self._momentsVM = StateObject(wrappedValue: vm)
    }
    
    private func calculateOffsetY(_ value: CGFloat) {
//        if momentsVM.pageIndex == index && !momentsVM.animationIsEnabled {
//            let offset = value - (proxy.size.height * CGFloat(index))
//            self.momentsVM.tabViewOffset = offset
//        }
//        
//        if value == 0 && momentsVM.isTapped {
//            momentsVM.animationIsEnabled = false
//        }
    }
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            ZStack(alignment: .top){
                Color.clear.frame(size)
                ForEach(Array(moments.moments.enumerated()), id: \.element.id, content: MomentItemView)
                    .overlay(alignment: .top) {
                        LinearGradient([Color.black.opacity(0.5), Color.clear], from: .top, to: .bottom)
                            .frame(maxWidth: .infinity)
                            .frame(height: UIDevice.current.statusBarHeight() + 44)
                            .opacity(momentsVM.onDragging || !momentsVM.viewIsReady ? 0.00001 : 1)
                    }
                    .overlay(alignment: .top) {
                        HStack {
                            AsyncButton {
                                await momentsVM.dismiss()
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 28, weight: .regular, design: .default))
                                    .foregroundColor(.white)
                            }
                            .buttonStyle(.plain)
                            Spacer()
                        }
                        .padding(.top, (UIDevice.current.hasNotch() ? UIDevice.current.statusBarHeight() : 0) + 15)
                        .padding(.horizontal, 10)
                        .opacity(momentsVM.onDragging || !momentsVM.viewIsReady ? 0.00001 : 1)
                    }
            }
            .offsetY(calculateOffsetY)
        }
        .frame(self.proxy.size)
        .tag(self.index)
        
    }
    
    @ViewBuilder
    private func MomentItemView(_ inx: Int, _ moment: Moment) -> some View {
        if inx == self.moments.currentIndex {
            MomentView(
                moment: self.$moments.moments[inx],
                moments: self.$moments,
                vm: momentsVM)
        }
       
    }
}
