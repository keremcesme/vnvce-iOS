
import SwiftUI
import SwiftUIX

extension HomeView {
    @ViewBuilder
    public var CameraView: some View {
        GeometryReader(content: _CameraView)
        
            .tag(homeVM.cameraRaw)
    }
    
    private func getScale(_ proxy: GeometryProxy) -> CGFloat {
        let minX = abs(proxy.frame(in: .global).minX)
        return abs(1 - minX / homeVM.momentSize.width / 4)
    }
    
    private func getOpacity(_ proxy: GeometryProxy) -> CGFloat {
        let minX = abs(proxy.frame(in: .global).minX)
        return 1 - minX / homeVM.momentSize.width * 1.5
    }
    
    @ViewBuilder
    private func _CameraView(_ proxy: GeometryProxy) -> some View {
        VStack(spacing: 10){
            NavigationTopLeading
                .opacity(getOpacity(proxy))
                .scaleEffect(getScale(proxy), anchor: .leading)
            _CameraView
                .scaleEffect(getScale(proxy))
        }
    }
    
    @ViewBuilder
    private var NavigationTopLeading: some View {
        VNVCELogo.TextAndLogo()
            .frame(height: homeVM.navBarHeight)
            .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private var _CameraView: some View {
        CameraViewUI()
            .background(.white.opacity(0.05))
//            .scaleEffect(homeVM.tab == homeVM.cameraRaw ? 1 : 0.99)
            .overlay(BlurLayer)
            .cornerRadius(25, style: .continuous)
            .animation(.default, value: homeVM.tab)
            .animation(.default, value: cameraManager.sessionIsRunning)
    }
    
    @ViewBuilder
    private var BlurLayer: some View {
        if (homeVM.tab != homeVM.cameraRaw || !cameraManager.sessionIsRunning) && (cameraManager.configurationStatus == .success) {
            BlurView(style: .dark)
//                .cornerRadius(25, style: .continuous)
        }
        
    }
}
