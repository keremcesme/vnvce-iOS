//
//  PostView+Preview.swift
//  vnvce
//
//  Created by Kerem Cesme on 19.09.2022.
//

import SwiftUI
import SwiftUIX
import PureSwiftUI

extension PostRootView {
    
    @ViewBuilder
    public var Preview: some View {
        if !postsVM.selectedPost.ready {
            Color.clear
                .overlay(alignment: postsVM.selectedPost.show ? .top : .center) {
                    Image(uiImage: postsVM.selectedPost.previewImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .greedyWidth()
                        .scaleEffect(previewScale())
                        .overlay {
                            BlurView(style: .regular)
                                .opacity(postsVM.selectedPost.show ? 0.000001 : 1)
                        }
                        .padding(.top, postsVM.selectedPost.show ? UIDevice.current.statusAndNavigationBarHeight : 0)
                }
        }
    }
    
    private func previewScale() -> CGFloat {
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
}
