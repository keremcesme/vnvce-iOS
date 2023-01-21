//
//  UserProfileBackground.swift
//  vnvce
//
//  Created by Kerem Cesme on 25.09.2022.
//

import SwiftUI
import Nuke
import NukeUI

struct UserProfileBackground: View {
    @Environment(\.colorScheme) var colorScheme
    
    let profilePicture: ProfilePicture?
    
    var body: some View {
        if let url = profilePicture?.returnURL {
            GeometryReader { g in
                ZStack {
                    
                    LazyImage(url: url) { state in
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
