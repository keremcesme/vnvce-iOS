
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
        if UIDevice.current.hasNotch() {
            _TabView
                .overlay(BottomView, alignment: .top)
                .padding(.top, 4)
                .ignoresSafeArea()
        } else {
            _TabView
                .overlay(BottomView, alignment: .top)
                .ignoresSafeArea()
        }
    }
    
    @ViewBuilder
    private var _TabView: some View {
        TabView(selection: $homeVM.currentTab, content: _TabViewContent)
            .tabViewStyle(.page(indexDisplayMode: .never))
//            .overlay {
//                Color.red.opacity(0.5)
//            }
            .ignoresSafeArea()
//            .addGestureRecognizer(homeVM.addGesture())
    }
    
    private func height() -> CGFloat {
        return homeVM.contentSize.height + homeVM.navBarHeight + 10
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
    
    @ViewBuilder
    private var MomentsView: some View {
        ForEach(Array(homeVM.usersAndTheirMoments.enumerated()), id: \.element.owner.id) { index, _ in
            UserMomentsView(index, $homeVM.usersAndTheirMoments[index])
        }
    }
    
}
