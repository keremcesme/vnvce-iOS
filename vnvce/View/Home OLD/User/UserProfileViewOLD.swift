//
//  UserProfileViewOLD.swift
//  vnvce
//
//  Created by Kerem Cesme on 11.09.2022.
//

import SwiftUI
import Introspect
import Nuke
import NukeUI
import PureSwiftUI
import SwiftUIX

struct UserProfileViewOLD: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject private var currentUserVM: CurrentUserViewModelOLD
    
    @StateObject public var userVM: UserProfileViewModelOLD
    @StateObject private var postsVM: PostsViewModel
    @StateObject private var momentsVM: MomentsViewModelOLD
    
    @StateObject private var scrollViewDelegate = RefreshableScrollViewModel()
    
    @StateObject var scrollDelegate = ScrollViewModel()
    
//    private let user: User.Public
    
    init(user: User.PublicOLD) {
        self._userVM = StateObject(wrappedValue: UserProfileViewModelOLD(user: user))
        self._postsVM = StateObject(wrappedValue: PostsViewModel(.user(userID: user.id)))
        self._momentsVM = StateObject(wrappedValue: MomentsViewModelOLD(payload: .user(userID: user.id)))
    }
    
    @Sendable
    private func commonInit() async {
//        TODO: Backend code is not ready.
        await userVM.fetchProfile()
        await userVM.fetchRelationship()
        if userVM.relationship?.raw == .friend {
//            await postsVM.loadFirstPage()
            await momentsVM.fetchMoments()
        }
    }
    
    var body: some View {
        ZStack {
            NavigationView {
                ZStack {
                    UserProfileBackground(profilePicture: userVM.user.profilePicture)
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack {
                                DetailsView
                                MomentsGridView(proxy: proxy, momentsVM: momentsVM)
                            }
                            .padding(.bottom, 75)
                        }
                        .refreshable(delegate: scrollViewDelegate) {
                            try? await Task.sleep(seconds: 2)
                        }
                        .addGestureRecognizer(scrollViewDelegate.gesture())
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbar(ToolBar)
//                .onAppear {
//                    scrollViewDelegate.addGesture()
//                }
            }
            MomentsRootView(momentsVM)
        }
        .navigationBarHidden(true)
        .taskInit(commonInit)
        
//        .onChange(of: postsVM.selectedPost.didAppear) {
//            if !$0 {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                    scrollDelegate.addGesture()
//                }
//            } else {
//                scrollDelegate.removeGesture()
//            }
//        }
//        .onChange(of: userVM.relationship) { value in
//            if value?.raw == .friend {
//                Task {
//                    await postsVM.loadFirstPage()
//                }
//            }
//        }
    }
    
    @ViewBuilder
    private var DetailsView: some View {
        VStack(alignment: .leading, spacing: 20){
            if let url = userVM.user.profilePicture?.returnURL {
                HStack {
                    Spacer()
                    ProfilePictureView(url)
                }
            }
            VStack(alignment: .leading, spacing: 5) {
                if let displayName = userVM.user.displayName {
                    DisplayNameView(displayName)
                }
                if let biography = userVM.user.biography {
                    BiographyView(biography)
                }
                UserProfileRelationshipButton(userVM: userVM)
            }
            
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    @ViewBuilder
    private func ProfilePictureView(_ url: URL) -> some View {
        GeometryReader { g in
            ZStack {
                LazyImage(url: url) { state in
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
}

extension UserProfileViewOLD {
    
    @ToolbarContentBuilder
    private var ToolBar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) { BackButton }
        ToolbarItem(placement: .principal) { UsernameLabel }
    }
    
    @ViewBuilder
    var BackButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "chevron.backward").font(.headline)
                .foregroundColor(.primary)
        }
    }
    
    @ViewBuilder
    private var UsernameLabel: some View {
        Text(userVM.user.username)
            .font(.headline)
            .frame(width: 150, alignment: .center)
    }
}
