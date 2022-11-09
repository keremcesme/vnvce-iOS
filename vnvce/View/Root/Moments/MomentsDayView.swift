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
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            ZStack(alignment: .top){
                Color.clear.frame(size)
                ForEach(Array(moments.moments.enumerated()), id: \.element.id, content: MomentItemView)
            }
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
