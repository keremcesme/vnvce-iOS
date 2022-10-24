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
                if let posts = postsVM.postResults.items,
                   let selectedPost = postsVM.selectedPost.post,
                   let index = posts.firstIndex(where: { $0 == selectedPost }) {
                    PostView(postsVM, post: $postsVM.postResults.items[index])
                }
//                if let post = postsVM.selectedPost.post {
//                    PostView(postsVM, post: post)
//                }

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
    
    @Binding public var post: Post
    
    init(_ postsVM: PostsViewModel, post: Binding<Post>) {
        self._postsVM = StateObject(wrappedValue: postsVM)
        self._post = post
    }
    
    private let width = UIScreen.main.bounds.width
    private let height = UIScreen.main.bounds.height
    
    public func dismiss() {
        DispatchQueue.main.async {
            postsVM.selectedPost.ready = false
            postVM.removeGesture()
            postVM.stopTimer()
            withAnimation(response: 0.25) {
                postVM.offset = .zero
                postsVM.selectedPost.show = false
            } after: {
                navigationController.navigation.enabled = true
                postsVM.selectedPost.didAppear = false
//                let index = postsVM.postResults.items.firstIndex(where: { $0 == postsVM.selectedPost.post! })
//                postsVM.postResults.items[index!].displayTime = Post.DisplayTime(id: UUID(), second: postVM.totalSeconds)
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
        .modifier(TimerController(postVM: postVM, postsVM: postsVM))
        .onAppear {
            if let postDisplay = postsVM.selectedPost.post!.displayTime {
                postVM.totalSeconds = postDisplay.second
                if postVM.totalSeconds >= 3 {
                    postVM.maxDuration = 4
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                postVM.addGesture(dismiss)
                postVM.startTimer()
            }
        }
//        .onChange(of: postVM.totalSeconds) { second in
//            Task {
//                var payload = PostDisplayTimePayload(postID: post.id,
//                                                     postDisplayTimeID: post.displayTime?.id,
//                                                     second: 0)
//                let second = Int(second) // 3
//                if Int(payload.second) != second {
//                    do {
//                        switch second {
//                        case (3):
//                            if Int(payload.second) != 3 {
//                                payload.second = 3
//                                print("🎃 HERE:  \(payload)")
//                                let result = try await postVM.setPostTimeTask(payload)
//                                post.displayTime = result
//                            }
////                        case (7):
////                            payload.second = 7
////                        case (11):
////                            payload.second = 11
////                        case (15):
////                            payload.second = 15
////                        case (19):
////                            payload.second = 19
////                        case (23):
////                            payload.second = 23
////                        case (27):
////                            payload.second = 27
//                        default:
//                            return
//                        }
//
//                    } catch {
//                        print(error.localizedDescription)
//                        return
//                    }
//                }
//
//
//            }
//        }
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
                HStack(spacing: 3){
                    Image(systemName: "timelapse")
                        .font(.system(size: 11, weight: .semibold, design: .default))
                    Text("\(postsVM.selectedPost.post!.totalWatchTime)s")
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

extension PostView {
    struct TimerController: ViewModifier {
        @StateObject public var postVM = PostViewModel()
        @StateObject public var postsVM = PostsViewModel()
        
        init(postVM: PostViewModel, postsVM: PostsViewModel) {
            self._postVM = StateObject(wrappedValue: postVM)
            self._postsVM = StateObject(wrappedValue: postsVM)
        }
        
        func body(content: Content) -> some View {
            content
                .onChange(of: postVM.onDragging) {
                    if $0 {
                        postVM.pauseTimer()
                    } else {
                        if postsVM.selectedPost.ready {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                postVM.startTimer()
                            }
                        }
                    }
                }
        }
    }
}

extension StringProtocol  {
    var digits: [Int] { compactMap(\.wholeNumberValue) }
}

extension LosslessStringConvertible {
    var string: String { .init(self) }
}

extension Numeric where Self: LosslessStringConvertible {
    var digits: [Int] { string.digits }
}
