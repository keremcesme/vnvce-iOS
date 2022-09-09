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
            .introspectNavigationController { controller in
                navigationController.properties(controller)
            }
//            .introspectNavigationController(customize: navigationController.properties)
            .environmentObject(keyboardController)
            .environmentObject(tabBarVM)
            .environmentObject(currentUserVM)
            .environmentObject(searchVM)
            .taskInit(commonInit)
        }
    }
    
}

// MARK: OLD

@available(iOS 15.0, *)
struct RefreshableView<Content: View>: View {
    
    var content: () -> Content
    
    @Environment(\.refresh) private var refresh   // << refreshable injected !!
    @State private var isRefreshing = false

    var body: some View {
        VStack {
            if isRefreshing {
                MyProgress()    // ProgressView() ?? - no, it's boring :)
                    .transition(.scale)
            }
            content()
        }
        .animation(.default, value: isRefreshing)
        .background(GeometryReader {
            // detect Pull-to-refresh
            Color.clear.preference(key: ViewOffsetKey.self, value: -$0.frame(in: .global).origin.y)
        })
        .onPreferenceChange(ViewOffsetKey.self) {
            if $0 < -80 && !isRefreshing {   // << any creteria we want !!
                isRefreshing = true
                Task {
                    await refresh?()           // << call refreshable !!
                    await MainActor.run {
                        isRefreshing = false
                    }
                }
            }
        }
    }
}

struct MyProgress: View {
    @State private var isProgress = false
    var body: some View {
        HStack{
            ProgressView().scaleEffect(self.isProgress ? 1.5:0.01)
//             ForEach(0...4, id: \.self){index in
//
//
//                  Circle()
//                        .frame(width:10,height:10)
//                        .foregroundColor(.red)
//                        .scaleEffect(self.isProgress ? 1:0.01)
//                        .animation(self.isProgress ? Animation.linear(duration:0.6).repeatForever().delay(0.2*Double(index)) :
//                             .default
//                        , value: isProgress)
//             }
        }
        .onAppear { isProgress = true }
        .padding()
    }
}

public struct ViewOffsetKey: PreferenceKey {
    public typealias Value = CGFloat
    public static var defaultValue = CGFloat.zero
    public static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}



//NavigationView {
//    ScrollView {
//        LazyVStack {
//            ForEach(1...100, id: \.self) { eachRowIndex in
//                Text("Row \(eachRowIndex)")
//            }
//        }
//    }
//    .introspectScrollView { scrollView in
//        target.use(for: scrollView) { refreshControl in
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                refreshControl.endRefreshing()
//            }
//        }
//    }
//            List {
//                ForEach(1...100, id: \.self) { eachRowIndex in
//                    Text("Row \(eachRowIndex)")
//                }
//            }
//            .introspectTableView { tableView in
//                target.use(for: tableView) { refreshControl in
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                        refreshControl.endRefreshing()
//                    }
//                }
//            }
//    .navigationTitle("ASDFASDF")
//}




//            .onAppear {
//                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { allowed, error in
//                    if allowed {
//                        DispatchQueue.main.async {
//                            UIApplication.shared.registerForRemoteNotifications()
//                        }
//                    } else {
//                        print(error?.localizedDescription)
//                    }
//                }
//            }
