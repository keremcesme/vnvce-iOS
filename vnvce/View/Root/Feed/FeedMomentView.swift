//
//  FeedMomentView.swift
//  vnvce
//
//  Created by Kerem Cesme on 22.10.2022.
//

import SwiftUI
import SwiftUIX
import PureSwiftUI

struct FeedMomentView: View {
    var body: some View {
        Moment
    }
    
    @ViewBuilder
    private var Moment: some View {
        GeometryReader{
            let size = $0.size
            VStack {
//                Text("title")
                RoundedRectangle(12)
                    .foregroundColor(.primary).opacity(0.1)
                    .frame(maxWidth: size.width)
                    .frame(height: size.width * 3 / 2)
            }
            .padding(.top, UIDevice.current.statusAndNavigationBarHeight)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 15)
    }
}
