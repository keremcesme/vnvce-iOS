//
//  CAProfilePictureAlignmentView.swift
//  vnvce
//
//  Created by Kerem Cesme on 23.08.2022.
//

import SwiftUI
import UIKit
import PureSwiftUI
import SwiftUIX

struct CAProfilePictureAlignmentView: View {
    @EnvironmentObject private var vm: CreateAccountViewModel
    
    private let yOffset = ((100 * 1.333) - 100) / 2
    
    let image: UIImage
    let alignment: Alignment
    
    init(image: UIImage, alignment: Alignment) {
        self.image = image
        self.alignment = alignment
    }
    
    @Sendable
    private func tapAction() {
        DispatchQueue.main.async {
            vm.profilePictureAlignment = alignment
        }
    }
    
    var body: some View {
        ButtonView.onPress(perform: tapAction)
//        Button(action: tapAction, label: ButtonView)
    }
    
    @ViewBuilder
    private var ButtonView: some View {
        VStack(spacing:5) {
            PictureView
            TitleLabel
        }
    }
    
    @ViewBuilder
    private var PictureView: some View {
        Group {
            if #available(iOS 15.0, *) {
                Picture
                    .mask(alignment: alignment){ MaskView }
            } else {
                Picture
                    .mask(MaskView)
            }
        }
        .overlay(OverlayView, alignment: alignment)
        .yOffset(offsetCondition())
    }
    
    @ViewBuilder
    private var Picture: some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 100, height: 100 * 1.333, alignment: .center)
    }
    
    private func offsetCondition() -> CGFloat {
        switch alignment {
            case .top:
                return yOffset
            case .bottom:
                return -yOffset
            default:
                return 0
        }
    }
    
    @ViewBuilder
    private var TitleLabel: some View {
        Group {
            switch alignment {
                case .top:
                    Text("Top")
                case .center:
                    Text("Center")
                case .bottom:
                    Text("Bottom")
                default:
                    Text("")
            }
        }
        .foregroundColor(.primary)
        .font(.system(size: 9, weight: .medium, design: .default))
        .padding(.horizontal, 5)
        .padding(.vertical, 2.5)
        .offset(0, -20)
    }
   
}


// MARK: Mask
extension CAProfilePictureAlignmentView {
    @ViewBuilder
    private var MaskView: some View {
        if #available(iOS 15.0, *) {
            Mask
        } else {
            VStack { Mask }
                .frame(maxWidth: 100, maxHeight: 100 * 1.333, alignment: alignment)
        }
    }
    
    @ViewBuilder
    private var Mask: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .frame(width: 100, height: 100, alignment: .center)
    }
}

// MARK: Overlay
extension CAProfilePictureAlignmentView {
    @ViewBuilder
    private var OverlayView: some View {
        if alignment != vm.profilePictureAlignment {
            Color.black.opacity(0.7)
                .cornerRadius(20, style: .continuous)
                .frame(width: 100, height: 100, alignment: .center)
        }
    }
}
