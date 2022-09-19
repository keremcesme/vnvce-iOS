//
//  PostView+NavigationBar.swift
//  vnvce
//
//  Created by Kerem Cesme on 19.09.2022.
//

import SwiftUI
import ActionOver

extension PostRootView {
    
    @ViewBuilder
    func NavigationBar(width: CGFloat) -> some View {
        BlurView(style: .systemMaterial)
            .frame(width: width, height: UIDevice.current.statusAndNavigationBarHeight)
            .overlay(alignment: .bottom) {
                Divider()
            }
            .opacity(-scrollDelegate.scrollOffset.y / 10)
            .overlay(BackButton, alignment: .bottomLeading)
    }
    
    @ViewBuilder
    private var BackButton: some View {
        Button(action: dismiss) {
            Image(systemName: "chevron.backward")
                .foregroundColor(.primary)
                .font(.system(size: 24, weight: .medium, design: .default))
                .frame(height: 44)
                .padding(.leading, 17)
        }
    }
}
