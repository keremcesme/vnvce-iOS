//
//  OffsetKey.swift
//  vnvce
//
//  Created by Kerem Cesme on 10.11.2022.
//

import SwiftUI

extension View {
    @ViewBuilder
    func offsetY(_ completion: @escaping (CGFloat) -> Void) -> some View {
        self
            .overlay {
                GeometryReader{
                    let minY = $0.frame(in: .global).minY
                    Color.clear
                        .preference(key: OffsetKey.self, value: minY)
                        .onPreferenceChange(OffsetKey.self, perform: completion)
                }
            }
    }
}

struct OffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
