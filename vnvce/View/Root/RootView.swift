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
    @StateObject var keyboardController = KeyboardController()
    @StateObject var navigationController = NavigationController()
    
    @StateObject private var rootVM = RootViewModel()
    
    @StateObject private var tabBarVM = TabBarViewModel()
    
    @StateObject private var currentUserVM = CurrentUserViewModel()
    @StateObject private var profileVM = ProfileViewModel()
    
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
        await currentUserVM.fetchProfile()
        await momentsVM.fetchMoments()
        await momentsVM2.fetchMoments()
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // MARK: Main View
//                MainView()
                
                
                Root
                
//                Root2
                
                
                // MARK: Other Views
//                SearchView()
//                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
//                    .colorScheme(.dark)
//                UserMomentsRootView(momentsVM, momentsVM2: momentsVM2)
                MomentsRootView(momentsVM2)
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
        
        .environmentObject(momentsVM)
        .environmentObject(momentsVM2)
        
        .environmentObject(searchVM)
        
        .environmentObject(cameraVM)
        .environmentObject(camera)
        
        
        
        .environmentObject(tabBarVM)
        
        .environmentObject(postsVM)
        .environmentObject(uploadPostVM)
    }
    
    @ViewBuilder
    private var Root: some View {
        GeometryReader {
            let size = $0.size
            HStack(alignment: .top, spacing: 0) {
                HomeView(size: size).background(Color.black)
                ProfileView(size: size)
            }
            .frame(size)
            .updateOffset($0, value: $rootVM.currentOffset)
        }
        .frame(width: UIScreen.main.bounds.width * 2)
        .frame(maxHeight: .infinity)
        .xOffset(UIScreen.main.bounds.width / 2 + rootVM.offset)
        .ignoresSafeArea()
        .onChange(of: rootVM.currentOffset, perform: rootVM.onChangeCurrentOffset)
        .onChange(of: rootVM.currentStatusBarStyle) { value in
            switch value {
            case .lightContent:
                self.camera.startSession()
            default:
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    if rootVM.currentStatusBarStyle == value {
                        self.camera.stopSession()
                    }
                }
            }
        }
    }
    
    
}

extension View {
    func updateOffset(_ proxy: GeometryProxy, value: Binding<CGFloat>) -> some View {
        modifier(RootViewModifier(proxy, value))
    }
}
