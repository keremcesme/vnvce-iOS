//
//  AuthView+Background.swift
//  vnvce
//
//  Created by Kerem Cesme on 12.08.2022.
//

import SwiftUI
import PureSwiftUI

struct AuthViewBackground: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        Image("bg")
             .resizable()
             .aspectRatio(contentMode: .fill)
             .frame(UIScreen.main.bounds.size)
             .overlay(Overlay)
             .ignoresSafeArea()
    }
    
    @ViewBuilder
    private var Overlay: some View {
        switch colorScheme {
            case .light:
                Color.white.opacity(0.5)
            case .dark:
                Color.black.opacity(0.7)
            @unknown default:
                Color.clear
        }
    }
}


