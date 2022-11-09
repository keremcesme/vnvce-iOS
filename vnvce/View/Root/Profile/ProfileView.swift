//
//  ProfileView.swift
//  vnvce
//
//  Created by Kerem Cesme on 6.11.2022.
//

import SwiftUI
import Introspect
import Nuke
import NukeUI
import PureSwiftUI
import SwiftUIX

struct ProfileView: View {
    @EnvironmentObject public var rootVM: RootViewModel
    @EnvironmentObject public var profileVM: ProfileViewModel
    
    @EnvironmentObject public var camera: CameraManager
    
    @EnvironmentObject public var currentUserVM: CurrentUserViewModel
    @EnvironmentObject public var momentsVM: UserMomentsViewModel
    @EnvironmentObject public var momentsVM2: MomentsViewModel
    
    @State private var showEditProfileView: Bool = false
    
    private var size: CGSize
    
    init(size: CGSize) {
        self.size = size
    }
    
    private func onRefresh() async {
        await currentUserVM.fetchProfile()
//        await momentsVM.fetchMoments()
        await momentsVM2.fetchMoments()
    }
    
    var body: some View {
        GeometryReader {_ in
            NavigationView {
                ZStack {
                    CurrentUserBackground()
                    ScrollViewReader { proxy in
                        ProfileScrollView(onRefresh) {
                            LazyVStack {
                                DetailsView
                                MomentsGridView(proxy: proxy, momentsVM: momentsVM, momentsVM2: momentsVM2)
                            }
                            .padding(.bottom, 200)
                        }
                        
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(ToolBar)
                .onChange(of: rootVM.currentTab) { value in
                    if value == .profile {
                        rootVM.addGestureToProfile()
                    } else {
                        rootVM.removeAllGestures()
                    }
                }
                .onChange(of: momentsVM2.show) {
                    if !$0 {
                        rootVM.removeAllGestures()
                        rootVM.addGestureToProfile()
                    }
                }
            }
            
        }
        .frame(width: size.width / 2, height: size.height)
//        .overlay(NavigationBar, alignment: .top)
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
                .processors([ImageProcessors.Resize(width: g.size.width)])
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


