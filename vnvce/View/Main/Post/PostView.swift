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
    
    init(_ postsVM: PostsViewModel) {
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
                if let post = postsVM.selectedPost.post {
                    PostView(postsVM, post: post)
                }

            }
        }
        
    }
}

struct PostView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject public var currentUserVM: CurrentUserViewModel
    @EnvironmentObject public var appState: AppState
    @EnvironmentObject var navigationController: NavigationController
    
    @StateObject public var postVM = PostViewModel()
    
    @StateObject public var postsVM: PostsViewModel
    
    @State public var post: Post
    
    init(_ postsVM: PostsViewModel, post: Post) {
        self._postsVM = StateObject(wrappedValue: postsVM)
        self._post = State(initialValue: post)
    }
    
    private let width = UIScreen.main.bounds.width
    private let height = UIScreen.main.bounds.height
    
    public func dismiss() {
        DispatchQueue.main.async {
            postsVM.selectedPost.ready = false
            postVM.removeGesture()
            withAnimation(response: 0.25) {
                postVM.offset = .zero
                postsVM.selectedPost.show = false
            } after: {
                navigationController.navigation.enabled = true
                postsVM.selectedPost.didAppear = false
            }
        }
    }
    
    var body: some View {
        PostScrollView(postVM) {
            PostView
        } onRefresh: {
            try? await Task.sleep(seconds: 1)
        }
        .modifier(PostProperties(post, postsVM, postVM))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                postVM.addGesture(dismiss)
            }
        }
        .onChange(of: appState.scenePhase) { newPhase in
            if newPhase == .inactive {
                print("Inactive")
            } else if newPhase == .active {
                print("Active")
            } else if newPhase == .background {
                print("Background")
            }
        }
    }
    
    @ViewBuilder
    private var PostView: some View {
        VStack {
            VStack(alignment: .leading, spacing:0) {
                MediaView
                    .overlay(PostViewBlur(postsVM: postsVM, postVM: postVM))
//                    .overlay {
//                        BlurView(style: .light)
//                            .opacity(postsVM.selectedPost.show ? 0.000001 : 1)
//                    }
                    .overlay {
                        ZStack {
                            EmptyView()
//                            if postVM.onDragging {
//                                BlurView(style: .light)
//                            }
//
//                            if postVM.stop {
//                                BlurView(style: .light)
//                                    .overlay {
//                                        VStack {
//                                            Image(systemName: "hand.tap.fill")
//                                                .foregroundColor(.white)
//                                                .font(.system(size: 45, weight: .medium, design: .default))
//                                            Text("tap to show")
//                                                .foregroundColor(.white)
//                                                .font(.system(size: 14, weight: .regular, design: .default))
//                                        }
//                                        .shadow(radius: 0.4)
//                                    }
//                            }
                        }
                        .animation(.default, value: postVM.onDragging)
                        .animation(.default, value: postVM.stop)
                    }
                    .overlay {
                        Color.black.opacity(0.0000001)
                            .onTapGesture {
                                if postVM.stop {
                                    postVM.stop = false
                                    postVM.startTimer()
                                } else {
                                    postVM.stop = true
                                    postVM.pauseTimer()
                                }
                            }
                    }
                HStack(spacing: 3){
                    Image(systemName: "timelapse")
                        .font(.system(size: 11, weight: .semibold, design: .default))
                    Text("\(postsVM.selectedPost.post!.totalSeconds)s")
                        .font(.system(size: 12, weight: .medium, design: .default))
                }
                .foregroundColor(.primary)
                .padding(5)
                .background {
                    Color.primary
                        .opacity(0.05)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 10)
                .padding(.top, 10)
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
    }
}
