
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
    
    private func getCornerRadius(_ proxy: GeometryProxy)  -> CGFloat {
        let minX = abs(proxy.frame(in: .global).minX)
        let radius = minX / 12.5
        return radius >= 25 ? 25 : radius
    }
    
    @ViewBuilder
    private func _CameraView(_ proxy: GeometryProxy) -> some View {
        if UIDevice.current.hasNotch() {
            VStack(spacing: 10){
                NavigationTopLeading
                    .opacity(getOpacity(proxy))
                    .scaleEffect(getScale(proxy), anchor: .leading)
                _CameraView
                    .scaleEffect(getScale(proxy))
            }
        } else {
            ZStack(alignment: .topLeading){
                _CameraView
                Group {
                    GradientForNoneNotch
                    NavigationTopLeading
                }
                    .opacity(getOpacity(proxy))
            }
            .cornerRadius(getCornerRadius(proxy), style: .continuous)
            .scaleEffect(getScale(proxy))
            .ignoresSafeArea()
        }
        
    }
    
    @ViewBuilder
    private var NavigationTopLeading: some View {
        VNVCELogo.TextAndLogo()
            .frame(height: homeVM.navBarHeight)
            .padding(.horizontal, 20)
            .padding(.top, !UIDevice.current.hasNotch() ? UIDevice.current.statusBarHeight() + 4 : 0)
    }
    
    @ViewBuilder
    private var GradientForNoneNotch: some View {
        LinearGradient(colors: [.black.opacity(0.5), .clear], startPoint: .top, endPoint: .bottom)
            .frame(height: UIDevice.current.statusBarHeight() + homeVM.navBarHeight + 10)
    }
    
    @ViewBuilder
    private var _CameraView: some View {
        Group {
            if UIDevice.current.hasNotch() {
                CameraViewUI()
                    .background(.white.opacity(0.05))
                    .overlay(BlurLayer)
                    .cornerRadius(25, style: .continuous)
            } else {
                CameraViewUI()
                    .background(.white.opacity(0.05))
                    .overlay(BlurLayer)
            }
        }
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
