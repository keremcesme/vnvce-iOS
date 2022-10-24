//
//  ProfileView.swift
//  vnvce
//
//  Created by Kerem Cesme on 7.09.2022.
//

import SwiftUI
import Introspect
import Nuke
import NukeUI
import PureSwiftUI
import SwiftUIX

struct ProfileView: View {
    @EnvironmentObject private var currentUserVM: CurrentUserViewModel
    @EnvironmentObject private var postsVM: PostsViewModel
    @EnvironmentObject private var cameraVM: CameraViewModel
    @EnvironmentObject private var momentsVM: MomentsViewModel
    
    @StateObject var scrollDelegate: ScrollViewModel = .init()
    
    @State private var showEditProfileView: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                CurrentUserBackground()
                ScrollViewReader { proxy in
                    ScrollViewRefreshable(scrollDelegate: scrollDelegate) {
                        LazyVStack {
                            DetailsView
//                            PostsGridView(vm: postsVM)
                            
                            
                            
                            GridLayout(items: momentsVM.moments, id: \.id, spacing: 1, columnCount: 3, cellRatio: 1.5) { post in
                                
                                
                                GeometryReader{
                                    let frame = $0.frame(in: .global)
                                    let size = $0.size
                                    
                                    LazyImage(url: URL(string: post.moments[0].media.url)) {
                                        if let uiImage = $0.imageContainer?.image {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(size)
                                                .clipped()
                                                .overlay {
                                                    BlurView(style: .light)
                                                }
                                                .contentShape(Rectangle())
                                                
                                        } else {
                                            Color.primary.opacity(0.05)
                                                .shimmering()
                                        }
                                    }
                                    .animation(nil)
                                    .pipeline(.shared)
                                    .processors([ImageProcessors.Resize(width: 100)])
                                    .priority(.veryHigh)
                                    
                                }
                                
                                
                                
                                
                                
                                
                            }
                            
                            
                            
                            
                            
                            NavigationLink {
                                EmptyView()
                            } label: {
                                Text("GO")
                                    .font(.title.bold())
                            }
                        }
                        .padding(.bottom, 75)
                    } onRefresh: {
                        await currentUserVM.fetchProfile()
//                        await postsVM.loadFirstPage()
                        await momentsVM.fetchMoments()
                    }
                    .onChange(of: postsVM.scrollToPostID) { id in
                        if (postsVM.selectedPost.frame.top.height < UIDevice.current.statusAndNavigationBarHeight) || (postsVM.selectedPost.frame.bottom.height > UIScreen.main.bounds.height - UIDevice.current.bottomSafeAreaHeight() - 60) {
                            proxy.scrollTo(id, anchor: .center)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                            postsVM.updateCurrentPostRectAfterScroll = true
                        }
                    }
//                    .onChange(of: cameraVM.viewDidAppear) {
//                        if !$0 {
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                                scrollDelegate.addGesture()
//                            }
//                        }
//                    }
                }
                .onChange(of: postsVM.selectedPost.didAppear) {
                    if !$0 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            scrollDelegate.addGesture()
                        }
                    } else {
                        scrollDelegate.removeGesture()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar(ToolBar)
        }
    }
    
    @ViewBuilder
    private var DetailsView: some View {
        if let user = currentUserVM.user {
            VStack(alignment: .leading, spacing: 20){
                if let url = user.profilePicture?.url {
                    HStack {
                        Spacer()
                        ProfilePictureView(url)
                    }
                }
                VStack(alignment: .leading, spacing: 5) {
                    if let displayName = user.displayName {
                        DisplayNameView(displayName)
                    }
                    if let biography = user.biography {
                        BiographyView(biography)
                    }
                    EditProfileButton
                }
                
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        } else {
            ProgressView()
                .frame(maxWidth: .infinity)
        }
    }
    
    @ViewBuilder
    private func ProfilePictureView(_ url: String) -> some View {
        GeometryReader { g in
            ZStack {
                LazyImage(url: URL(string: url)) { state in
                    if let uiImage = state.imageContainer?.image {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(g.size)
                            .clipped()
                    }
                }
                .pipeline(.shared)
                .processors([ImageProcessors.Resize(width: 200)])
                .priority(.normal)
            }
        }
        .frame(width: UIScreen.main.bounds.width / 2.5, height: (UIScreen.main.bounds.width / 2.5) * 1.333, alignment: .center)
        .cornerRadius(20, style: .continuous)
    }
    
    @ViewBuilder
    private func DisplayNameView(_ name: String) -> some View {
        Text(name).font(.largeTitle).bold()
    }
    
    @ViewBuilder
    private func BiographyView(_ bio: String) -> some View {
        Text(bio)
            .font(.system(size: 11, weight: .regular, design: .default))
            .multilineTextAlignment(.leading)
            .lineLimit(5)
    }
    
    @ViewBuilder
    private var EditProfileButton: some View {
        Button {
            showEditProfileView = true
        } label: {
            Text("Edit Profile")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(Color.primary.opacity(0.05).cornerRadius(7.5, style: .continuous))
        }
        .buttonStyle(.plain)
        .padding(.top, 10)
        .fullScreenCover(isPresented: $showEditProfileView) {
            EditProfileView().environmentObject(currentUserVM)
        }
    }
}

extension ProfileView {
    
    @ToolbarContentBuilder
    private var ToolBar: some ToolbarContent {
        ToolbarItem(placement: .principal) { UsernameLabel }
    }
    
    @ViewBuilder
    private var UsernameLabel: some View {
        Text(currentUserVM.user?.username ?? "")
            .font(.headline)
            .frame(width: 150, alignment: .center)
        
    }
}
