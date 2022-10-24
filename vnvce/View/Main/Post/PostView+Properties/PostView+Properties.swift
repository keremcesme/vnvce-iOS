//
//  PostView+Properties.swift
//  vnvce
//
//  Created by Kerem Cesme on 19.09.2022.
//

import SwiftUI
import SwiftUIX
import PureSwiftUI

extension PostView {
    
    struct PostProperties: ViewModifier {
        @Environment(\.colorScheme) var colorScheme
        
        @EnvironmentObject public var currentUserVM: CurrentUserViewModel
        
        @StateObject public var postsVM: PostsViewModel
        @StateObject public var postVM: PostViewModel
        
        public var post: Post
        
        init(_ post: Post,
             _ postsVM: PostsViewModel,
             _ postVM: PostViewModel) {
            self.post = post
            self._postsVM = StateObject(wrappedValue: postsVM)
            self._postVM = StateObject(wrappedValue: postVM)
            
        }
        
        private var postViewScaleEffect: CGFloat {
            if postsVM.selectedPost.show {
                if postVM.offset.width < 0 {
                    return 1.0
                } else {
                    let max = UIScreen.main.bounds.width / 1.5
                    let currentAmount = abs(postVM.offset.width)
                    let percentage = currentAmount / max
                    return 1.0 - min(percentage, 0.2)
                }
            } else {
                return 0.5
            }
        }
        
        func body(content: Content) -> some View {
            content
                .overlay(NavigationBar, alignment: navigationBarAlignment)
                .overlay(TimerBar, alignment: bottomBarAlignment)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .opacity(postsVM.selectedPost.show ? 1 : 0.00001)
                .background(Background)
                .overlay(PreviewImage)
                .cornerRadius(UIDevice.current.screenCornerRadius, style: .continuous)
                .scaleEffect(postViewScaleEffect)
                .mask(Mask)
                .offset(postVM.offset)
                .offsetToPositionIf(!postsVM.selectedPost.show, postsVM.selectedPost.frame.center)
                .ignoresSafeArea()
        }
        
        @ViewBuilder
        var Mask: some View {
            RoundedRectangle(postsVM.selectedPost.show ? UIDevice.current.screenCornerRadius : 0, style: .continuous)
                .frame(postsVM.selectedPost.show ? UIScreen.main.bounds.size : postsVM.selectedPost.size)
                .ignoresSafeArea()
        }
        
        @ViewBuilder
        private var Background: some View {
            BlurView(style: .regular)
                .background {
                    if colorScheme == .light {
                        Color.white.opacity(0.5)
                    }
                }
        }
        
    }
}
