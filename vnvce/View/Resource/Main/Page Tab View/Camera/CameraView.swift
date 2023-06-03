
import SwiftUI
import SwiftUIX
import PureSwiftUI

struct CameraView: View {
    @EnvironmentObject private var homeVM: HomeViewModel
    @EnvironmentObject private var cameraManager: CameraManager
    
    public var body: some View {
        GeometryReader(content: GeometryReaderContent).tag(homeVM.cameraRaw)
    }
    
    @ViewBuilder
    private func GeometryReaderContent(_ proxy: GeometryProxy) -> some View {
        _View(proxy)
    }
}

private extension CameraView {
    struct _View: View {
        @EnvironmentObject public var homeVM: HomeViewModel
        @EnvironmentObject public var cameraManager: CameraManager
        
        private var proxy: GeometryProxy
        
        public init(_ proxy: GeometryProxy) {
            self.proxy = proxy
        }
        
        private var setScale: CGFloat {
            let minX = abs(proxy.frame(in: .global).minX)
            return abs(1 - minX / homeVM.contentSize.width / 4)
        }
        
        private var setOpacity: CGFloat {
            let minX = abs(proxy.frame(in: .global).minX)
            return 1 - minX / homeVM.contentSize.width * 1.5
        }
        
        private var setBlurOpacity: CGFloat {
            let minX = abs(proxy.frame(in: .global).minX)
            return minX / homeVM.contentSize.width * 2
        }
        
        private var setCornerRadius: CGFloat {
            let minX = abs(proxy.frame(in: .global).minX)
            let radius = minX / 15
            return radius >= 15 ? 15 : radius
        }
        
        var body: some View {
            Group {
                switch UIDevice.current.hasNotch() {
                case true: NotchView
                case false: NonNotchView
                }
            }
            .animation(.default, value: homeVM.currentTab)
            .animation(.default, value: cameraManager.sessionIsRunning)
            .animation(.default, value: cameraManager.outputWillShowed)
        }
        
        @ViewBuilder
        private var NotchView: some View {
            VStack(spacing: 10){
                NavigationBar
                    .opacity(setOpacity)
                    .scaleEffect(setScale, anchor: .leading)
                CameraView
                    .scaleEffect(setScale)
            }
        }
        
        @ViewBuilder
        private var NonNotchView: some View {
            ZStack(alignment: .topLeading){
                CameraView
                Group {
                    GradientForNoneNotch
                    NavigationBar
                }
                .opacity(setOpacity)
            }
            .cornerRadius(setCornerRadius)
            .scaleEffect(setScale)
        }
        
        @ViewBuilder
        private var CameraView: some View {
            Group {
                switch UIDevice.current.hasNotch() {
                case true:
                    CameraViewUI()
                        .overlay(BlurLayer)
                        .cornerRadius(setCornerRadius)
                case false:
                    CameraViewUI()
                        .overlay(BlurLayer)
                }
            }
            .opacity(cameraManager.outputDidShowed ? 0 : 1)
        }
        
        @ViewBuilder
        private var BlurLayer: some View {
            if !cameraManager.sessionIsRunning && cameraManager.configurationStatus == .success {
                BlurView(style: .dark)
                    .opacity(setBlurOpacity)
            }
        }
        
        @ViewBuilder
        private var GradientForNoneNotch: some View {
            LinearGradient(colors: [.black.opacity(0.5), .clear], startPoint: .top, endPoint: .bottom)
                .frame(height: UIDevice.current.statusBarHeight() + homeVM.navBarHeight + 10)
        }
    }
}

private extension CameraView._View {
    
    @ViewBuilder
    private var NavigationBar: some View {
        GeometryReader(content: NavigationBar)
            .frame(height: homeVM.navBarHeight)
            .padding(.horizontal, 20)
            .padding(.top, !UIDevice.current.hasNotch() ? UIDevice.current.statusBarHeight() + 4 : 0)
            .opacity(!cameraManager.outputWillShowed ? 1 : 0.00001)
    }
    
    
    
    @ViewBuilder
    private func NavigationBar(_ proxy: GeometryProxy) -> some View {
        let height = proxy.size.height
        HStack(spacing: 15) {
            VNVCELogo.TextAndLogo().frame(height: height)
            Spacer()
        }
    }
}
