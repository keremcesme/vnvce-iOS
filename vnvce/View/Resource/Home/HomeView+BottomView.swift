
import SwiftUI
import SwiftUIX
import Introspect

extension HomeView {
    
    @ViewBuilder
    public var BottomView: some View {
        ScrollView(.horizontal, showsIndicators: false, content: ShutterAndUserMoments)
            .padding(.top, topPadding())
            .onChange(of: homeVM.tab, perform: onChangeTab)
            .opacity(!cameraManager.outputWillShowed ? 1 : 0.00001)
            .animation(.default, value: cameraManager.outputWillShowed)
    }
    
    private func topPadding() -> CGFloat {
        if UIDevice.current.hasNotch() {
            return homeVM.momentSize.height + homeVM.navBarHeight + UIDevice.current.statusBarHeight() + 10 + 15
        } else {
            return homeVM.momentSize.height + 10
        }
    }
    
    private func onChangeTab(_ id: String) {
        if id == homeVM.cameraRaw {
            cameraManager.startSession()
            homeVM.bottomResetScroll()
            userMomentsStore.currentMoment = nil
        } else {
            cameraManager.stopSession()
            if let index = userMomentsStore.usersWithMoments.firstIndex(where: { $0.owner.id.uuidString == homeVM.tab }) {
                homeVM.bottomScrollTo(index)
            }
        }
    }
    
    @ViewBuilder
    private func ShutterAndUserMoments() -> some View {
        HStack(alignment: .top, spacing: 15) {
            ShutterButton.id(homeVM.cameraRaw)
            Users
            ReturnHomeButton
        }
        .padding(.horizontal, homeVM.bottomPadding)
        .introspectScrollView(customize: homeVM.bottomScrollViewConnector)
    }
    
    
    
    @ViewBuilder
    private var ReturnHomeButton: some View {
        Button {
            homeVM.tab = "CAMERA"
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
        ForEach(Array(userMomentsStore.usersWithMoments.enumerated()), id: \.element.owner.id) {
            UserCell($0, user: $1.owner, moments: $1.moments)
        }
    }
    
}

// SHUTTER BUTTON
extension HomeView {
    
    private func shutterButtonAction() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if homeVM.tab == homeVM.cameraRaw {
            cameraManager.capturePhoto()
        } else {
            homeVM.tab = homeVM.cameraRaw
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
                    .opacity(homeVM.tab == homeVM.cameraRaw ? 1 : 0.1)
                if homeVM.tab != homeVM.cameraRaw {
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
                        self.shareMomentVM.setAnimationRect(rect)
                    }
            }
            .frame(48)
            .xOffset(-homeVM.bottomPadding / 2 - 48 / 2)
        }
        
    }
}
