
import SwiftUI
import Introspect

extension HomeView {
    
    @ViewBuilder
    public var BottomView: some View {
        ScrollView(.horizontal, showsIndicators: false, content: ShutterAndUserMoments)
            .padding(.top, topPadding())
            .onChange(of: homeVM.tab, perform: onChangeTab)
    }
    
    private func topPadding() -> CGFloat {
        if UIDevice.current.hasNotch() {
            return homeVM.momentSize.height + homeVM.navBarHeight + 10 + 15
        } else {
            return homeVM.momentSize.height + 10
        }
    }
    
    private func onChangeTab(_ id: String) {
        if id == homeVM.cameraRaw {
            cameraManager.startSession()
            homeVM.bottomResetScroll()
        } else {
            cameraManager.stopSession()
            if let index = homeVM.testUsers.firstIndex(where: { $0.id.uuidString == homeVM.tab }) {
                homeVM.bottomScrollTo(index)
            }
        }
    }
    
    @ViewBuilder
    private func ShutterAndUserMoments() -> some View {
        HStack(alignment: .top, spacing: 15) {
            ShutterButton.id(homeVM.cameraRaw)
            Users
        }
        .padding(.horizontal, homeVM.bottomPadding)
        .introspectScrollView(customize: homeVM.bottomScrollViewConnector)
    }
    
    @ViewBuilder
    private var ShutterButton: some View {
        Button {
            if homeVM.tab == "CAMERA" {
                if cameraManager.sessionIsRunning {
                    cameraManager.capturePhoto()
                }
            } else {
                homeVM.tab = "CAMERA"
                homeVM.bottomResetScroll()
            }
        } label: {
            ZStack {
                BlurView(style: .systemUltraThinMaterialDark)
                    .frame(width: 66, height: 66, alignment: .center)
                    .clipShape(Circle())
                Circle()
                    .strokeBorder(.white, lineWidth: 6)
                    .foregroundColor(Color.clear)
                    .frame(width: 72, height: 72, alignment: .center)
                    .opacity(homeVM.tab == "CAMERA" ? 1 : 0.1)
                if homeVM.tab != "CAMERA" {
                    Image("Home")
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                }
            }
        }
    }
    
    @ViewBuilder
    private var Users: some View {
        ForEach(Array(homeVM.testUsers.enumerated()), id: \.element.id, content: UserCell)
    }
}
