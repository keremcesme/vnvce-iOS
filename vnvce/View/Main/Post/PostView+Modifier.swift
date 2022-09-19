//
//  PostView+Modifier.swift
//  vnvce
//
//  Created by Kerem Cesme on 19.09.2022.
//

import SwiftUI
import SwiftUIX
import PureSwiftUI

extension PostRootView {
    struct Modifier: ViewModifier {
        private let width = UIScreen.main.bounds.width
        private let height = UIScreen.main.bounds.height
        
        @StateObject var postsVM: PostsViewModel
        @StateObject var postVM: PostViewModel
        @StateObject var scrollDelegate: PostScrollViewModel
        
        let dissmis: () async -> Void
        
        init(postsVM: PostsViewModel,
             postVM: PostViewModel,
             scrollDelegate: PostScrollViewModel,
             dissmis: @escaping () async -> Void
        ) {
            self._postsVM = StateObject(wrappedValue: postsVM)
            self._postVM = StateObject(wrappedValue: postVM)
            self._scrollDelegate = StateObject(wrappedValue: scrollDelegate)
            self.dissmis = dissmis
        }
        
        func body(content: Content) -> some View {
//            let gesture = LongPressGesture(minimumDuration: 0)
//                .sequenced(
//                    before: DragGesture(minimumDistance: 0)
//                        .onChanged(onChanged)
//                        .onEnded(onEnded))
            
            content
                .cornerRadius(UIDevice.current.screenCornerRadius(), style: .continuous)
                .scaleEffect(scaleAmount)
                .mask(Mask)
                .offset(scrollDelegate.offset)
                .offsetToPositionIf(!postsVM.selectedPost.show, postsVM.selectedPost.rect.origin)
                .ignoresSafeArea()
//                .onTapGesture { }
//                .gesture(gesture)
        }
        
        @ViewBuilder
        var Mask: some View {
            RoundedRectangle(postsVM.selectedPost.show ? 6.5 : 0, style: .continuous)
                .frame(
                    postsVM.selectedPost.show ? CGSize(width, height) : postsVM.selectedPost.rect.size
                )
        }
        
        private var scaleAmount: CGFloat {
            if self.postsVM.selectedPost.show {
                if self.scrollDelegate.offset.width < 0 {
                    return 1.0
                } else {
                    let max = UIScreen.main.bounds.width / 1.5
                    let currentAmount = abs(self.scrollDelegate.offset.width)
                    let percentage = currentAmount / max
                    return 1.0 - min(percentage, 0.2)
                }
            } else {
                return 0.5
            }
        }
        
//        private func onChanged(_ value: DragGesture.Value) {
//            DispatchQueue.main.async {
//                if !postVM.isDragging { postVM.isDragging = true}
////                print("SwiftUI: \(value.translation)")
////                postVM.offset = CGSize(value.translation.width / 1.5,
////                                       value.translation.height / 1.5)
//            }
//        }
//
//        private func onEnded(_ value: DragGesture.Value) {
//            DispatchQueue.main.async {
////                if value.translation.width >= 50 || value.translation.height >= 50 {
////                    Task {
////                        await dissmis()
////                    }
////                } else {
////                    if postVM.isDragging { postVM.isDragging = false}
////                    withAnimation(.spring(
////                        response: 0.25,
////                        dampingFraction: 1,
////                        blendDuration: 0
////                    )) {
////                        postVM.offset = .zero
////                    }
////                }
//            }
//        }
        
    }
}
