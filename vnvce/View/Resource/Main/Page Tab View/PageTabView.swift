
import SwiftUI
import SwiftUIX
import Introspect

struct PageTabView<Moments: View, Users: View>: View {
    @EnvironmentObject public var homeVM: HomeViewModel
    
    private var moments: Moments
    private var users: Users
    
    public init(
        @ViewBuilder moments: () -> Moments,
        @ViewBuilder users: () -> Users
    ) {
        self.moments = moments()
        self.users = users()
    }
    
    var body: some View {
        GeometryReader(content: GeometryReaderContent)
            .ignoresSafeArea()
    }
    
    @ViewBuilder
    private func GeometryReaderContent(_ proxy: GeometryProxy) -> some View {
        
        TabView(selection: $homeVM.currentTab, content: TabViewContent)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .overlay(alignment: .top, content: OverlayContent)
    }
    
    @ViewBuilder
    private func TabViewContent() -> some View {
//        Group {
            switch UIDevice.current.hasNotch() {
            case true:
                TabViewContentGroup()
            case false:
                Group(content: TabViewContentGroup)
                    .ignoresSafeArea()
            }
//        }
//        .introspectScrollView(customize: scrollViewConnector)
    }
    
    @ViewBuilder
    private func TabViewContentGroup() -> some View {
        CameraView()
        // MARK: MOMENTS
        self.moments
    }
    
    private func discoveryButtonAction() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        homeVM.currentTab = homeVM.cameraRaw
    }
    
    @ViewBuilder
    private func OverlayContent() -> some View {
        UsersScrollView(discoveryButtonAction) {
            self.users
        }
    }
    
    private func scrollViewConnector(_ scrollView: UIScrollView) {
        scrollView.bounces = false
    }
    
}
