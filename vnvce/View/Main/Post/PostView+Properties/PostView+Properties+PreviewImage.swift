//
//  PostView+Properties+PreviewImage.swift
//  vnvce
//
//  Created by Kerem Cesme on 24.09.2022.
//

import SwiftUI
import PureSwiftUI

extension PostView.PostProperties {
    
    private var previewImageAlignment: Alignment {
        switch postsVM.selectedPost.show {
        case true:
            return .top
        case false:
            return .center
        }
    }
    
    private var previewImageTopPadding: CGFloat {
        switch postsVM.selectedPost.show {
        case true:
            return UIDevice.current.statusAndNavigationBarHeight
        case false:
            return 0
        }
    }
    
    private var previewImageScaleEffect: CGFloat {
        let image = postsVM.selectedPost.previewImage
        let scale = image.size.width / image.size.height
        if image.size.width > image.size.height {
            if postsVM.selectedPost.show {
                return 1
            } else {
                return scale
            }
        } else {
            return 1
        }
    }
    
    @ViewBuilder
    public var PreviewImage: some View {
        if !postsVM.selectedPost.ready {
            Color.clear
                .overlay(alignment: previewImageAlignment) {
                    Image(uiImage: postsVM.selectedPost.previewImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(self.post.media.returnSize)
                        .scaleEffect(previewImageScaleEffect)
//                        .overlay(PreviewImageBlurLayer)
                        .overlay(PostViewBlur(postsVM: postsVM, postVM: postVM))
                        .padding(.top, previewImageTopPadding)
                }
                
        }
    }
    
    @ViewBuilder
    private var PreviewImageBlurLayer: some View {
        BlurView(style: .light)
            .opacity(postsVM.selectedPost.show ? 0.00001 : 1)
    }
    
}
