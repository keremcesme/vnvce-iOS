//
//  PostView.swift
//  vnvce
//
//  Created by Kerem Cesme on 19.09.2022.
//

import SwiftUI
import SwiftUIX
import PureSwiftUI

struct PostView: View {
    
    @StateObject private var postsVM: PostsViewModel
    
    @State private var scale: CGFloat = 0.5
    
    init(postsVM: PostsViewModel) {
        self._postsVM = StateObject(wrappedValue: postsVM)
    }
    
    var body: some View {
        ZStack {
            EmptyView()
            if postsVM.selectedPost.didAppear {
                EmptyView()
                if postsVM.selectedPost.show {
                    Color.black.opacity(0.2).ignoresSafeArea()
                }
                PostRootView(postsVM: postsVM)
            }
        }
        
    }
}

struct PostRootView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var postsVM: PostsViewModel
    @StateObject var postVM: PostViewModel = .init()
    @StateObject var scrollDelegate: PostScrollViewModel = .init()
    
    @State public var scrollOffset: CGFloat = 0
    
    init(postsVM: PostsViewModel) {
        self._postsVM = StateObject(wrappedValue: postsVM)
    }
    
    public func dismiss() {
        DispatchQueue.main.async {
            postsVM.selectedPost.ready = false
            withAnimation(response: 0.25) {
                scrollDelegate.offset = .zero
                postsVM.selectedPost.show = false
            } after: {
//                navigationController.navigation.enabled = true
//                commentsVM.comments.removeAll()
                postsVM.selectedPost.didAppear = false
            }
        }
    }
    
    var body: some View {
        Root
            .background(Background)
            .overlay(Preview)
            .modifier(Modifier(postsVM: postsVM, postVM: postVM, scrollDelegate: scrollDelegate, dissmis: dismiss))
            .onAppear {
                self.scrollDelegate.dismiss = dismiss
            }
    }
    
    @ViewBuilder
    private var Root: some View {
        GeometryReader{
            let size = $0.size
            let width = size.width
            let height = size.height
            
            ScrollViewReader{ proxy in
                PostScrollView(scrollDelegate: scrollDelegate){
                        VStack {
                            MediaView
                                .overlay {
                                    BlurView(style: .regular)
                                        .opacity(postsVM.selectedPost.show ? 0.000001 : 1)
                                }
                            Rectangle().foregroundColor(.primary).opacity(0.1)
                                .frame(maxWidth: .infinity)
                                .frame(height: 300)
                            Rectangle().foregroundColor(.primary).opacity(0.2)
                                .frame(maxWidth: .infinity)
                                .frame(height: 300)
                            Rectangle().foregroundColor(.primary).opacity(0.1)
                                .frame(maxWidth: .infinity)
                                .frame(height: 300)
                            Rectangle().foregroundColor(.primary).opacity(0.2)
                                .frame(maxWidth: .infinity)
                                .frame(height: 300)
                            Rectangle().foregroundColor(.primary).opacity(0.1)
                                .frame(maxWidth: .infinity)
                                .frame(height: 300)
                        }
//                        .padding(.horizontal, 20)
                    } onRefresh: {
                        try? await Task.sleep(seconds: 2)
                    }
                
            }
            .frame(width: width, height: height - UIDevice.current.bottomSafeAreaHeight() - 12)
            .mask(Rectangle())
            .overlay(NavigationBar(width: width), alignment: .top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
