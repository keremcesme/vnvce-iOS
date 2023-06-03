
import SwiftUI
import Introspect

extension MainView {
    
    public struct PageView<Moments: View, Users: View>: View {
        @EnvironmentObject private var homeVM: HomeViewModel
        
        private var moments: Moments
        private var users: Users
        
        public init(
            @ViewBuilder moments: () -> Moments,
            @ViewBuilder users: () -> Users
        ) {
            self.moments = moments()
            self.users = users()
        }
        
        public var body: some View {
            GeometryReader { _ in PageTabView }.ignoresSafeArea()
        }
        
        @ViewBuilder
        private var PageTabView: some View {
            TabView(selection: $homeVM.currentTab, content: PageTabViewContent)
                .tabViewStyle(.page(indexDisplayMode: .never))
                // BOTTOM OVERLAY
        }
        
        @ViewBuilder
        private func PageTabViewContent() -> some View {
            CameraView().introspectScrollView(customize: scrollViewConnector)
            self.moments
        }
        
        private func scrollViewConnector(_ scrollView: UIScrollView) {
            scrollView.bounces = false
        }
    }
    
}

extension HomeView {
    
    
    
    @ViewBuilder
    public var PageView: some View {
        GeometryReader(content: _PageView)
            .ignoresSafeArea(.keyboard, edges: .bottom)
    }
    
    @ViewBuilder
    private func _PageView(_ proxy: GeometryProxy) -> some View {
        if UIDevice.current.hasNotch() {
            _TabView
                .padding(.top, 4)
        } else {
            _TabView
                .ignoresSafeArea()
        }
    }
    
    @ViewBuilder
    private var _TabView: some View {
        TabView(selection: $homeVM.currentTab, content: _TabViewContent)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()
            .overlay(BottomView, alignment: .top)
    }
    
    @ViewBuilder
    private func _TabViewContent() -> some View {
        Group {
            CameraVieww
            MomentsView
        }
        .introspectScrollView(customize: scrollViewConnector)
    }
    
    private func scrollViewConnector(_ scrollView: UIScrollView) {
        scrollView.bounces = false
    }
    
    @ViewBuilder
    private var MomentsView: some View {
        ForEach(Array(homeVM.usersAndTheirMoments.enumerated()), id: \.element.user.detail.id) { index, vm in
            Color.primary.opacity(0.1)
                .overlay {
                    Text("\(vm.currentMomentIndex)")
                }
                .tag(vm.user.detail.id.uuidString)
//            UserMomentsView(index, homeVM.usersAndTheirMoments[index])
        }
    }
    
}
