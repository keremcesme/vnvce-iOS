//
//  UserMomentsDayView.swift
//  vnvce
//
//  Created by Kerem Cesme on 2.11.2022.
//

import SwiftUI
import SwiftUIX
import PureSwiftUI

struct UserMomentsDayView: View {
    @StateObject public var momentsVM: UserMomentsViewModelOLD
    
    @Binding private var moments: Moments
    
    private var index: Int
    private var proxy: GeometryProxy
    
    init(
        moments: Binding<Moments>,
        index: Int,
        proxy: GeometryProxy,
        momentsVM: UserMomentsViewModelOLD
    ) {
        self._moments = moments
        self.index = index
        self.proxy = proxy
        self._momentsVM = StateObject(wrappedValue: momentsVM)
    }
    
    private func getScale(proxy: GeometryProxy, index: Int) -> CGFloat {
        var scale: CGFloat = 1
        let x = proxy.frame(in: .global).minY
        let diff = abs(x)
        scale = 1 + (200 - diff) / 1000
        if scale > 1.0 {
            scale = 1.0
        }
        return scale
    }
    
    var body: some View {
        let scale = getScale(proxy: proxy, index: self.index)
        ForEach(Array(self.moments.moments.enumerated()),
            id: \.element.id) { inx, _ in
//            if inx == momentsDayVM.currentIndex {
            if inx == self.moments.currentIndex {
                UserMomentView(
                    size: proxy.size,
                    moment: self.$moments.moments[inx],
                    momentsDayIndex: self.index,
                    momentsVM: momentsVM)
                .overlay(alignment: .top) {
                    LinearGradient([Color.black.opacity(0.5), Color.clear], from: .top, to: .bottom)
                        .frame(maxWidth: .infinity)
                        .frame(height: UIDevice.current.statusBarHeight() + 44)
                }
                .overlay(alignment: .top) {
                    HStack {

                        Spacer()
                        Button {
                            self.momentsVM.dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 28, weight: .regular, design: .default))
                                .foregroundColor(.white)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, (UIDevice.current.hasNotch() ? UIDevice.current.statusBarHeight() : 0) + 15)
                    .padding(.horizontal, 15)
                }
            }
        }
    }
}
