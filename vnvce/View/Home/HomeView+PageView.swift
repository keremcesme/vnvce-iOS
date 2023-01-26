
import SwiftUI
import Introspect

extension HomeView {
    @ViewBuilder
    public var PageView: some View {
        GeometryReader(content: _PageView)
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
    
    @ViewBuilder
    private func _PageView(_ proxy: GeometryProxy) -> some View {
        VStack(spacing: 15) {
            _TabView
            BottomView
        }
        .overlay(NavigationBar, alignment: .top)
        .padding(.top, 4)
    }
    
    @ViewBuilder
    private var _TabView: some View {
        TabView(selection: $homeVM.tab, content: _TabViewContent)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: height())
    }
    
    private func height() -> CGFloat {
        return homeVM.momentSize.height + homeVM.navBarHeight + 10
    }
    
    @ViewBuilder
    private func _TabViewContent() -> some View {
        Group {
            CameraView
            MomentsView
        }
        .introspectScrollView(customize: scrollViewConnector)
    }
    
    private func scrollViewConnector(_ scrollView: UIScrollView) {
        scrollView.bounces = false
    }
    
}
