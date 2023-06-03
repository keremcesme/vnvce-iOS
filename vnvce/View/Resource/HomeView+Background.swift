
import SwiftUI
import PureSwiftUI
import Colorful

extension HomeView {
    
    @ViewBuilder
    public var Background: some View {
        BlurView(style: .systemThinMaterial)
            .background(_Background)
            .overlay(_Overlay)
//            .overlay(.black.opacity(homeVM.currentTab == homeVM.cameraRaw && !cameraManager.outputDidShowed ? 1 : 0.5))
//            .overlay(.black.opacity(0.5))
            .animation(.default, value: homeVM.currentTab)
//            .animation(.default, value: userMomentsStore.currentMoment)
            .animation(.default, value: homeVM.backgroundImage)
            .animation(.default, value: cameraManager.capturedPhoto)
            .ignoresSafeArea()
    }
    
    @ViewBuilder
    private var _Background: some View {
        ZStack {
//            Color.black
            Group {
                ColorfulView()
                
                if let outputImage = cameraManager.capturedPhoto?.image {
                    Image(uiImage: outputImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Image(uiImage: returnImage())
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
            }
            .frame(homeVM.screen.size)
        }
    }
    
    @ViewBuilder
    private var _Overlay: some View {
        if colorScheme == .dark {
            Color.black.opacity(0.4)
        }
    }
    
    private func returnImage() -> UIImage {
        if let backgroundImage = homeVM.backgroundImage {
            return backgroundImage
        } else {
            return UIImage()
        }
    }
    
}
