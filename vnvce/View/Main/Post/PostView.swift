//
//  PostView.swift
//  vnvce
//
//  Created by Kerem Cesme on 19.09.2022.
//

import SwiftUI
import SwiftUIX
import PureSwiftUI
import Nuke
import NukeUI

struct PostRootView: View {
    @StateObject private var postsVM: PostsViewModel
    
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
                PostView(postsVM)
            }
        }
        
    }
}

struct PostView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var postsVM: PostsViewModel
    
    init(_ postsVM: PostsViewModel) {
        self._postsVM = StateObject(wrappedValue: postsVM)
    }
    
    @StateObject var postVM = PostViewModel()
    @StateObject var scrollDelegate = PostScrollViewModel()
    
    private let width = UIScreen.main.bounds.width
    private let height = UIScreen.main.bounds.height
    
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
        PostView
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    scrollDelegate.addGesture(dismiss)
                }
            }
            .onDisappear(perform: scrollDelegate.removeGesture)
    }
    
    @ViewBuilder
    private var Root: some View {
        GeometryReader{
            let size = $0.size
//            let width = size.width
//            let height = size.height
            
            ScrollViewReader{ proxy in
                PostScrollView(scrollDelegate: scrollDelegate){
                        VStack {
                            VStack(alignment: .leading, spacing:0) {
                                MediaView
                                    .overlay {
                                        BlurView(style: .light)
                                            .opacity(postsVM.selectedPost.show ? 0.000001 : 1)
                                    }
                                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit ut aliquam, purus sit amet luctus venenatis, lectus")
                                    .foregroundColor(.primary)
                                    .font(.system(size: 12, weight: .regular, design: .default))
                                    .multilineTextAlignment(.leading)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 10)
//                                    .background(Color.primary.opacity(0.01))
                            }

                            Rectangle().foregroundColor(.primary).opacity(0.00001)
                                .frame(maxWidth: .infinity)
                                .frame(height: 300)
                            Rectangle().foregroundColor(.primary).opacity(0.00002)
                                .frame(maxWidth: .infinity)
                                .frame(height: 300)
                            Rectangle().foregroundColor(.primary).opacity(0.00001)
                                .frame(maxWidth: .infinity)
                                .frame(height: 300)
                            Rectangle().foregroundColor(.primary).opacity(0.00002)
                                .frame(maxWidth: .infinity)
                                .frame(height: 300)
                            Rectangle().foregroundColor(.primary).opacity(0.00001)
                                .frame(maxWidth: .infinity)
                                .frame(height: 300)
                        }
//                        .padding(.horizontal, 20)
                    } onRefresh: {
                        try? await Task.sleep(seconds: 2)
                    }

            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            scrollDelegate.addGesture(dismiss)
        }
        .onDisappear(perform: scrollDelegate.removeGesture)
    }
    
    @ViewBuilder
    private var PostView: some View {
        GeometryReader { g in
            PostScrollView(scrollDelegate: scrollDelegate) {
                VStack {
                    VStack(alignment: .leading, spacing:0) {
                        MediaView
                            .overlay {
                                BlurView(style: .light)
                                    .opacity(postsVM.selectedPost.show ? 0.000001 : 1)
                            }
                        Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit ut aliquam, purus sit amet luctus venenatis, lectus")
                            .foregroundColor(.primary)
                            .font(.system(size: 12, weight: .regular, design: .default))
                            .multilineTextAlignment(.leading)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 10)
//                                    .background(Color.primary.opacity(0.01))
                    }
                    
                    Rectangle().foregroundColor(.primary).opacity(0.00001)
                        .frame(maxWidth: .infinity)
                        .frame(height: 300)
                    Rectangle().foregroundColor(.primary).opacity(0.00002)
                        .frame(maxWidth: .infinity)
                        .frame(height: 300)
                    Rectangle().foregroundColor(.primary).opacity(0.00001)
                        .frame(maxWidth: .infinity)
                        .frame(height: 300)
                    Rectangle().foregroundColor(.primary).opacity(0.00002)
                        .frame(maxWidth: .infinity)
                        .frame(height: 300)
                    Rectangle().foregroundColor(.primary).opacity(0.00001)
                        .frame(maxWidth: .infinity)
                        .frame(height: 300)
                }
            } onRefresh: {
                try? await Task.sleep(seconds: 1)
            }

        }
        .opacity(postsVM.selectedPost.show ? 1 : 0.00001)
        .overlay(NavigationBar, alignment: postsVM.selectedPost.show ? .top : .center)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Background)
        .overlay(PreviewImage)
        .cornerRadius(UIDevice.current.screenCornerRadius, style: .continuous)
        .scaleEffect(scaleAmount)
//        .frame(postsVM.selectedPost.show ? UIScreen.main.bounds.size : postsVM.selectedPost.size)
        .mask(Mask)
        .offset(scrollDelegate.offset)
        .offsetToPositionIf(!postsVM.selectedPost.show, postsVM.selectedPost.frame.center)
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    var Mask: some View {
        RoundedRectangle(postsVM.selectedPost.show ? UIDevice.current.screenCornerRadius : 0, style: .continuous)
            .frame(postsVM.selectedPost.show ? UIScreen.main.bounds.size : postsVM.selectedPost.size)
            .ignoresSafeArea()
    }
    
    private var scaleAmount: CGFloat {
        if postsVM.selectedPost.show {
            if scrollDelegate.offset.width < 0 {
                return 1.0
            } else {
                let max = UIScreen.main.bounds.width / 1.5
                let currentAmount = abs(scrollDelegate.offset.width)
                let percentage = currentAmount / max
                return 1.0 - min(percentage, 0.2)
            }
        } else {
            return 0.5
        }
    }
    
    @ViewBuilder
    private var PreviewImage: some View {
        if !postsVM.selectedPost.ready {
            Color.clear
                .overlay(alignment: postsVM.selectedPost.show ? .top : .center) {
                    Image(uiImage: postsVM.selectedPost.previewImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .greedyWidth()
                        .scaleEffect(previewScale())
                        .overlay {
                            BlurView(style: .light)
                                .opacity(postsVM.selectedPost.show ? 0.000001 : 1)
                        }
                        .padding(.top, postsVM.selectedPost.show ?
                        UIDevice.current.statusAndNavigationBarHeight : 0)
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
