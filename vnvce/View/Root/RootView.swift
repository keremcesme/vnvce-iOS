//
//  RootView.swift
//  vnvce
//
//  Created by Kerem Cesme on 20.08.2022.
//

import SwiftUI
import SwiftUIX
import PureSwiftUI
import Introspect
import Nuke
import NukeUI

struct RootView: View {
    @StateObject private var image = FetchImage()
    
    @StateObject var keyboardController = KeyboardController()
    @StateObject var navigationController = NavigationController()
    
    @StateObject private var rootVM = RootViewModel()
    
    @StateObject private var tabBarVM = TabBarViewModel()
    
    @StateObject private var currentUserVM = CurrentUserViewModel()
    @StateObject private var profileVM = ProfileViewModel()
    @StateObject private var profileScrollViewDelegate = RefreshableScrollViewModel()
    
    @StateObject private var feedVM = FeedViewModel()
    
    @StateObject private var searchVM = SearchViewModel()
    @StateObject private var postsVM = PostsViewModel()
    
    @StateObject private var momentsVM = UserMomentsViewModel()
    @StateObject private var momentsVM2 = MomentsViewModel()
    
    @StateObject private var uploadPostVM = UploadPostViewModel()
    
    @StateObject private var camera = CameraManager()
    @StateObject private var cameraVM = CameraViewModel()
    
    @State private var offset: CGFloat = 0
    @State private var location: CGPoint = .zero
    
    @Sendable
    private func commonInit() async {
//        await currentUserVM.fetchProfile()
//        await momentsVM.fetchMoments()
//        await momentsVM2.fetchMoments()
    }
    
    var body: some View {
        NavigationView {
            ZStack {
//                Color.black.ignoresSafeArea()
                
//                PageView
                
                FeedView()
                
                if camera.image != nil {
                    Color.red
                }
                
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .introspectNavigationController { controller in
                navigationController.properties(controller)
            }
            .taskInit(commonInit)
        }
        .environmentObject(keyboardController)
        .environmentObject(navigationController)
        .environmentObject(rootVM)
        
        .environmentObject(currentUserVM)
        .environmentObject(profileVM)
        .environmentObject(profileScrollViewDelegate)
        
        .environmentObject(momentsVM)
        .environmentObject(momentsVM2)
        
        .environmentObject(searchVM)
        
        .environmentObject(cameraVM)
        .environmentObject(camera)
        
        .environmentObject(feedVM)
        
        .environmentObject(tabBarVM)
        
        .environmentObject(postsVM)
        .environmentObject(uploadPostVM)
    }
    
    @ViewBuilder
    private var PageView: some View {
        ScrollViewReader { proxy in
            GeometryReader { g in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        HomeView().id(0)
                        ProfileView().id(1)
                    }
                    .introspectScrollView {
                        $0.isPagingEnabled = true
                        $0.bounces = false
                        $0.contentInsetAdjustmentBehavior = .never
                    }
                    .offsetX(rootVM.onChangeOffset)
                    .onChange(of: rootVM.profileWillShowed) {
                        rootVM.onChangeProfileWillShowed($0, proxy: proxy)
                    }
                    .onChange(of: rootVM.homeWillShowed) {
                        rootVM.onChangeHomeWillShowed($0, proxy: proxy)
                    }
                    .onChange(of: rootVM.currentTab) {
                        if $0 == .profile {
//                            self.profileScrollViewDelegate.addGesture()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                if rootVM.currentTab == .profile {
                                    self.camera.stopSession()
                                }
                            }
                        } else {
//                            self.profileScrollViewDelegate.deleteGesture()
                            self.camera.startSession()
                        }
                    }
                }
            }
            
            .ignoresSafeArea(.keyboard)
        }
        .ignoresSafeArea()
    }
}
