//
//  PostView+Blur.swift
//  vnvce
//
//  Created by Kerem Cesme on 5.10.2022.
//

import SwiftUI

struct PostViewBlur: View {
    @EnvironmentObject public var appState: AppState
    
    @StateObject private var postsVM: PostsViewModel
    @StateObject private var postVM: PostViewModel
    
    @State private var showBlur: Bool = true
    
    init(
        postsVM: PostsViewModel,
        postVM: PostViewModel
    ) {
        self._postsVM = StateObject(wrappedValue: postsVM)
        self._postVM = StateObject(wrappedValue: postVM)
    }
    
    var body: some View {
        ZStack {
            EmptyView()
            if showBlur {
                BlurView(style: .light)
//                    .opacity(blurOpacity)
            }
        }
        .animation(.spring(response: 0.25, dampingFraction: 0.95, blendDuration: 1), value: showBlur)
        .onChange(of: postsVM.selectedPost.show) {
            self.showBlur = !$0
        }
        .onChange(of: postVM.onDragging) {
            self.showBlur = $0
        }
        .onChange(of: postVM.stop) {
            self.showBlur = $0
        }
        .onChange(of: appState.scenePhase) { value in
            DispatchQueue.main.async {
                self.showBlur = value != .active
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.userDidTakeScreenshotNotification)) { _ in
            self.showBlur = true
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                self.showBlur = false
//            }
        }
    }
    
//    private var showBlurView: Bool {
//        if !postsVM.selectedPost.show {
//            return true
//        } else {
//            return false
//        }
//    }
    
    private var blurOpacity: CGFloat {
        
        if !postsVM.selectedPost.show {
            return 1
        } else {
            return 0.00001
        }
    }
    
}
