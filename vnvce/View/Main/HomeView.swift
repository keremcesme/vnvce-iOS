//
//  HomeView.swift
//  vnvce
//
//  Created by Kerem Cesme on 20.08.2022.
//

import SwiftUI
import Introspect

struct HomeView: View {
    @StateObject var keyboardController = KeyboardController()
    @StateObject var navigationController = NavigationController()
    
    @StateObject private var tabBarVM = TabBarViewModel()
    
    @StateObject private var searchVM = SearchViewModel()
    @StateObject private var currentUserVM = CurrentUserViewModel()
    
    @Sendable
    private func commonInit() async {
        await currentUserVM.fetchProfile()
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                TabView(selection: $tabBarVM.current) {
                    FeedView()
                        .tag(Tab.feed)
                    ProfileView()
                        .tag(Tab.profile)
                }
                .introspectTabBarController {
                    $0.tabBar.isHidden = true
                }
                TabBar()
                // MARK: Other Views
                // ...
                SearchView()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .introspectNavigationController { controller in
                navigationController.properties(controller)
            }
            .environmentObject(keyboardController)
            .environmentObject(tabBarVM)
            .environmentObject(currentUserVM)
            .environmentObject(searchVM)
            .taskInit(commonInit)
        }
    }
    
}
