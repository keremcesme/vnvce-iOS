//
//  UserProfileView.swift
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

struct UserProfileView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject public var userVM: UserProfileViewModel
    
    @StateObject var scrollDelegate = ScrollViewModel()
    
//    private let user: User.Public
    
    init(user: User.Public) {
        self._userVM = StateObject(wrappedValue: UserProfileViewModel(user: user))
    }
    
    @Sendable
    private func commonInit() async {
        await userVM.fetchRelationship()
    }
    
    var body: some View {
        ZStack {
            NavigationView {
                ZStack {
                    UserProfileBackground(profilePicture: userVM.user.profilePicture)
                    ScrollViewReader { proxy in
                        ScrollViewRefreshable(scrollDelegate: scrollDelegate) {
                            LazyVStack {
                                DetailsView
//                                Text(userVM.relationship.rawString)
//                                    .font(.largeTitle.bold())
//                                PostsGridView(vm: postsVM)
                            }
                            .padding(.bottom, 75)
                        } onRefresh: {
//                            await currentUserVM.fetchProfile()
//                            await postsVM.loadFirstPage()
                            await commonInit()
                            try? await Task.sleep(seconds: 1)
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbar(ToolBar)
            }
//            NavigationLink {
//                UserProfileView(user: userVM.user)
//            } label: {
//                Text("GO")
//                    .font(.largeTitle.bold())
//            }
        }
        .navigationBarHidden(true)
        .taskInit(commonInit)
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

extension UserProfileView {
    
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
