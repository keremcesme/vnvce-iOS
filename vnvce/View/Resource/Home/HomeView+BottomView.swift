
import SwiftUI
import SwiftUIX
import Introspect

extension HomeView {
    
    @ViewBuilder
    public var BottomView: some View {
        ScrollView(.horizontal, showsIndicators: false, content: ShutterAndUserMoments)
            .padding(.top, topPadding())
            .onChange(of: homeVM.currentTab, perform: onChangeTab)
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
    
    private func onChangeTab(_ id: String) {
        if id == homeVM.cameraRaw {
            cameraManager.startSession()
            homeVM.bottomResetScroll()
            userMomentsStore.currentMoment = nil
        } else {
            cameraManager.stopSession()
            if let index = homeVM.usersAndTheirMoments.firstIndex(where: { $0.owner.id.uuidString == homeVM.currentTab }) {
                homeVM.bottomScrollTo(index)
            }
        }
    }
    
    @ViewBuilder
    private func ShutterAndUserMoments() -> some View {
        HStack(alignment: .top, spacing: 15) {
            ShutterButton.id(homeVM.cameraRaw)
//            HDiv
            Users
//            ReturnHomeButton
        }
        .padding(.horizontal, homeVM.bottomScrollViewPadding)
        .introspectScrollView(customize: homeVM.bottomScrollViewConnector)
    }
    
    @ViewBuilder
    private var HDiv: some View {
        Rectangle()
            .fill(.white.opacity(0.1))
            .frame(1, 20)
    }
    
    @ViewBuilder
    private var ReturnHomeButton: some View {
        Button {
            homeVM.currentTab = homeVM.cameraRaw
            homeVM.bottomResetScroll()
        } label: {
            Image(systemName: "arrow.uturn.backward")
                .foregroundColor(.white)
                .font(.system(size: 28, weight: .regular, design: .default))
                .frame(68)
        }
        .buttonStyle(.scaled)
    }
    
    @ViewBuilder
    private var Users: some View {
        ForEach(Array(homeVM.usersAndTheirMoments.enumerated()), id: \.element.owner.id) {
            UserCell($0, user: $1.owner, moments: $1.moments)
        }
    }
}

// SHUTTER BUTTON
extension HomeView {
    
    private func shutterButtonAction() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if homeVM.currentTab == homeVM.cameraRaw {
            cameraManager.capturePhoto()
        } else {
            homeVM.currentTab = homeVM.cameraRaw
            homeVM.bottomResetScroll()
        }
    }
    
    @ViewBuilder
    public var ShutterButton: some View {
        Button(action: shutterButtonAction) {
            ZStack {
                BlurView(style: .systemUltraThinMaterialDark)
                    .frame(width: 66, height: 66, alignment: .center)
                    .clipShape(Circle())
                Circle()
                    .strokeBorder(.white, lineWidth: 6)
                    .foregroundColor(Color.clear)
                    .frame(homeVM.cell.size)
                    .opacity(homeVM.currentTab == homeVM.cameraRaw ? 1 : 0.1)
                if homeVM.currentTab != homeVM.cameraRaw {
                    Image("Home")
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                }
            }
        }
        .buttonStyle(.scaled)
        .overlay(alignment: .leading){
            GeometryReader {
                let size = $0.size
                let frame = $0.frame(in: .global)
                
                Circle()
                    .foregroundColor(.red)
                    .frame(size)
                    .taskInit {
                        let rect = CGRect(frame.center, size)
                        self.currentUserVM.setMyMomentsRect(rect)
                    }
            }
            .frame(48)
            .xOffset(-homeVM.bottomScrollViewPadding / 2 - 48 / 2)
        }
        
    }
    
}
