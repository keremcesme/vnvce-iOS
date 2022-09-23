//
//  PostsView.swift
//  vnvce
//
//  Created by Kerem Cesme on 22.09.2022.
//

import SwiftUI
import SwiftUIX
import PureSwiftUI

struct PostsRootView: View {
    
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
                PostsView(postsVM)
            }
        }
    }
}

struct PostsView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject private var postsVM: PostsViewModel
    @StateObject private var scrollDelegate = PostsScrollViewModel()
    
    init(_ postsVM: PostsViewModel) {
        self._postsVM = StateObject(wrappedValue: postsVM)
    }
    
    private let width = UIScreen.main.bounds.width
    private let height = UIScreen.main.bounds.height
    
    // MARK: DISMISS VIEW ACTION
    private func dismiss() {
        DispatchQueue.main.async {
            postsVM.selectedPost.ready = false
            withAnimation(response: 0.25) {
                scrollDelegate.contentOffset = .zero
                postsVM.selectedPost.show = false
            } after: {
                //                navigationController.navigation.enabled = true
                postsVM.selectedPost.didAppear = false
            }
        }
    }
    
    var body: some View {
        PostsView
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                scrollDelegate.addGesture(dismiss)
            }
        }
        .onDisappear(perform: scrollDelegate.removeGesture)
    }
    
    @ViewBuilder
    private var PostsView: some View {
        GeometryReader{ g in
            ScrollViewReader { proxy in
                PostsScroll
            }
            .overlay {
                if !postsVM.selectedPost.ready {
                    Color.black.opacity(0.000001)
                }
            }
        }
        .overlay(NavigationBar, alignment: .top)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Background)
        .overlay(PreviewImage)
        .cornerRadius(UIDevice.current.screenCornerRadius, style: .continuous)
        .scaleEffect(scaleAmount)
        .mask(Mask)
        .offset(scrollDelegate.contentOffset)
        .offsetToPositionIf(!postsVM.selectedPost.show, postsVM.selectedPost.frame.center)
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    private var PostsScroll: some View {
        PostsScrollView(scrollDelegate) {
            ForEach(postsVM.postResults.items[postsVM.currentPostIndex...postsVM.postResults.items.count - 1], id: \.id){ post in
                if let index = postsVM.postResults.items.firstIndex(where: {$0 == post}) {
                    PostsCellView(post: $postsVM.postResults.items[index], postsVM: postsVM, scrollDelegate: scrollDelegate)
//                        .opacity(postsVM.selectedPost.show ? 1 : 0.00001)
                        .task(if: post == postsVM.postResults.items.last, postsVM.loadNextPage)
                }
                
            }
//            ForEach(enumeratedPosts(), id: \.element.id){ _, post in
//                if let index = post.index {
//                    PostsCellView(post: $postsVM.postResults.items[index], postsVM: postsVM)
//                        .task(if: post == postsVM.postResults.items.last, postsVM.loadNextPage)
//                } else {
//                    if let index = postsVM.postResults.items.firstIndex(where: {$0 == post}) {
//                        PostsCellView(post: $postsVM.postResults.items[index], postsVM: postsVM)
//                            .task(if: post == postsVM.postResults.items.last, postsVM.loadNextPage)
//                    }
//                }
//            }
        }
    }
    
    private func enumeratedPosts() -> [EnumeratedSequence<Array<Post>.SubSequence>.Element] {
        let posts = postsVM.postResults.items
        let startIndex = postsVM.currentPostIndex
        let endIndex = posts.count - 1
        
        return Array(posts[startIndex...endIndex].enumerated())
    }
    
    @ViewBuilder
    private var Background: some View {
        CurrentUserBackground()
//        BlurView(style: .regular)
//            .background {
//                if colorScheme == .light {
//                    Color.white.opacity(0.5)
//                }
//            }
    }
    
    @ViewBuilder
    var Mask: some View {
        RoundedRectangle(postsVM.selectedPost.show ? UIDevice.current.screenCornerRadius : 0, style: .continuous)
            .frame(postsVM.selectedPost.show ? CGSize(width, height) : postsVM.selectedPost.size)
            .ignoresSafeArea()
    }
    
    private var scaleAmount: CGFloat {
        if postsVM.selectedPost.show {
            if scrollDelegate.contentOffset.width < 0 {
                return 1.0
            } else {
                let max = UIScreen.main.bounds.width / 1.5
                let currentAmount = abs(scrollDelegate.contentOffset.width)
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
//                                .opacity(postsVM.selectedPost.show ? 0.000001 : 1)
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
    
    
}

extension PostsView {
    
    @ViewBuilder
    private var NavigationBar: some View {
        BlurView(style: .systemMaterial)
            .greedyWidth()
            .frame(height: UIDevice.current.statusAndNavigationBarHeight)
            .overlay(alignment: .bottom) {
                Divider()
            }
            .opacity(-scrollDelegate.scrollOffset / 10)
            .opacity(postsVM.selectedPost.show ? 1 : 0.00001)
            .overlay(BackButton, alignment: .bottomLeading)
    }
    
    @ViewBuilder
    private var BackButton: some View {
        Button(action: dismiss) {
            HStack {
                Image(systemName: "chevron.backward")
                    .foregroundColor(.primary)
                    .font(.system(size: 24, weight: .medium, design: .default))
                    .frame(height: 44)
                    .padding(.leading, 17)
                Text("Posts")
                    .foregroundColor(.primary)
                    .font(.system(size: 24, weight: .bold, design: .default))
            }
            
        }
    }
}
