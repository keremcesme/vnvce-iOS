//
//  FrameKey.swift
//  vnvce
//
//  Created by Kerem Cesme on 12.11.2022.
//

import SwiftUI

extension View {
    @ViewBuilder
    func viewWidth(_ width: Binding<CGFloat>) -> some View {
        self
            .overlay {
                GeometryReader {
                    let max = $0.size.width
                    Color.clear
                        .preference(key: FrameKey.self, value: max)
                        .onPreferenceChange(FrameKey.self) { value in
                            width.wrappedValue = value
                        }
                }
            }
    }
    
    @ViewBuilder
    func viewWidth2(_ width: Binding<CGFloat>) -> some View {
        self
            .overlay {
                GeometryReader {
                    let max = $0.size.width
                    Color.clear
                        .preference(key: FrameKey.self, value: max)
                        .onPreferenceChange(FrameKey.self) { value in
                            width.wrappedValue = value
                        }
                }
            }
    }
}

struct FrameKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
