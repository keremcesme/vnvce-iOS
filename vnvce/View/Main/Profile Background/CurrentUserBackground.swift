//
//  CurrentUserBackground.swift
//  vnvce
//
//  Created by Kerem Cesme on 7.09.2022.
//

import SwiftUI
import Nuke
import NukeUI

struct CurrentUserBackground: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
//        Background
        if let url = UserDefaults.standard.value(forKey: "profilePictureURL") as? String {
            
            GeometryReader { g in
                ZStack {
                    
                    LazyImage(url: URL(string: url)) { state in
                        if let uiImage = state.imageContainer?.image {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(g.size)
                                .clipped()
                        }
                    }
                    .pipeline(.shared)
                    .processors([ImageProcessors.Resize(width: 200)])
                    .priority(.normal)
                    Overlay
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .ignoresSafeArea()
        }
    }
    
    @ViewBuilder
    private var Overlay: some View {
        switch colorScheme {
            case .dark:
                BlurView(style: .systemMaterial)
                    .overlay(Color.black.opacity(0.5))
            case .light:
                BlurView(style: .systemMaterial)
            @unknown default:
                EmptyView()
        }
    }
}
