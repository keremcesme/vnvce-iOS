
import SwiftUI

extension HomeView {
    
    @ViewBuilder
    public var BottomView: some View {
        ScrollViewReader(content: _BottomView)
    }
    
    @ViewBuilder
    private func _BottomView(_ proxy: ScrollViewProxy) -> some View {
        ScrollView(.horizontal, showsIndicators: false, content: ShutterAndUserMoments)
            .onChange(of: homeVM.tab) { onChangeTab($0, proxy) }
    }
    
    private func onChangeTab(_ id: String, _ proxy: ScrollViewProxy) {
        if id == homeVM.cameraRaw {
            cameraManager.startSession()
        } else {
            cameraManager.stopSession()
        }
        withAnimation(.easeInOut(duration: 0.2)) {
            proxy.scrollTo(id, anchor: .center)
        }
    }
    @ViewBuilder
    private func ShutterAndUserMoments() -> some View {
        HStack(alignment: .top, spacing: 15) {
            ShutterButton.id(homeVM.cameraRaw)
            Users
        }
        .padding(.horizontal, 200 )
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
