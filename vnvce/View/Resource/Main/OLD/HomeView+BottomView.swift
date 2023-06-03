
import SwiftUI
import SwiftUIX
import PureSwiftUI
import Introspect

extension HomeView {
    
    @ViewBuilder
    public var BottomView: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false, content: ShutterAndUserMoments)
                .padding(.top, topPadding())
                .onChange(of: homeVM.currentTab) {
                    onChangeTab($0, proxy)
                }
        }
        
        .opacity(!cameraManager.outputWillShowed ? 1 : 0.00001)
        .animation(.default, value: cameraManager.outputWillShowed)
    }
    
    private func topPadding() -> CGFloat {
        if UIDevice.current.hasNotch() {
            return homeVM.contentSize.height + homeVM.navBarHeight + UIDevice.current.statusBarHeight() + 10 + 15
        } else {
            return homeVM.contentSize.height + 10
        }
    }
    
    private func onChangeTab(_ id: String, _ proxy: ScrollViewProxy) {
        if id == homeVM.cameraRaw {
            cameraManager.startSession()
            homeVM.backgroundImage = nil
            withAnimation {
                proxy.scrollTo(id, anchor: .center)
            }
        } else {
            cameraManager.stopSession()
            withAnimation {
                proxy.scrollTo(id, anchor: .center)
            }
        }
    }
    
    @ViewBuilder
    private func ShutterAndUserMoments() -> some View {
        LazyHStack(alignment: .top, spacing: 15) {
            DiscoveryAndCameraButton.id(homeVM.cameraRaw)
            HDiv
            Users
        }
        .padding(.horizontal, homeVM.bottomScrollViewPadding)
//        .introspectScrollView(customize: homeVM.bottomScrollViewConnector)
    }
    
    @ViewBuilder
    private var HDiv: some View {
        Capsule()
            .fill(.primary.opacity(0.15))
            .frame(1, 30)
            .yOffset(homeVM.cell.size / 2 - 15)
    }
    
    @ViewBuilder
    private var Users: some View {
//        ForEach(Array($homeVM.usersAndTheirMoments.enumerated()), id: \.element.user.detail.id) { index, $vm in
//            UserCellView(index, vm)
//        }
        
        Text("asdfasdfas")
    }
}

extension HomeView {
    
    private func discoveryAndCameraButtonAction() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if homeVM.currentTab != homeVM.cameraRaw {
            homeVM.currentTab = homeVM.cameraRaw
        }
    }
    
    @ViewBuilder
    public var DiscoveryAndCameraButton: some View {
        Button(action: discoveryAndCameraButtonAction) {
            VStack(spacing: 7) {
                ZStack {
                    Circle()
                        .fill(.primary.opacity(0.1))
                        .frame(homeVM.cell.size)
                    Group {
                        if homeVM.currentTab == homeVM.cameraRaw {
                            Image("discovery_icon")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            Image("camera_fill_icon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                
                        }
                    }
                    .foregroundColor(.primary)
                    .opacity(0.85)
                    .frame(width: 30, height: 30)
                    .transition(.scale.combined(with: .opacity))
                }
                if homeVM.currentTab == homeVM.cameraRaw {
                    Image(systemName: "chevron.down")
                        .foregroundColor(.secondary)
                        .font(.system(size: 16, weight: .semibold, design: .default))
                        .transition(.opacity.combined(with: .scale))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: homeVM.currentTab)
        }
        .buttonStyle(.scaled)
//        .overlay(alignment: .topLeading){
//            GeometryReader {
//                let size = $0.size
//                let frame = $0.frame(in: .global)
//
//                Circle()
//                    .foregroundColor(.red)
//                    .frame(size)
//                    .taskInit {
//                        let rect = CGRect(frame.center, size)
//                        self.currentUserVM.setMyMomentsRect(rect)
//                    }
//            }
//            .frame(48)
//            .offset(x: -homeVM.bottomScrollViewPadding / 2 - 48 / 2, y: homeVM.cell.size.height / 2)
//        }
        
    }
    
}
