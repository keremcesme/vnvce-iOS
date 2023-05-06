
import SwiftUI
import PureSwiftUI
import Colorful

extension HomeView {
    
    @ViewBuilder
    public var Background: some View {
        BlurView(style: .systemMaterialDark)
            .background(_Background)
//            .overlay(.black.opacity(homeVM.currentTab == homeVM.cameraRaw && !cameraManager.outputDidShowed ? 1 : 0.5))
            .overlay(.black.opacity(0.5))
            .animation(.default, value: homeVM.currentTab)
            .animation(.default, value: userMomentsStore.currentMoment)
            .animation(.default, value: cameraManager.capturedPhoto)
            .ignoresSafeArea()
    }
    
    @ViewBuilder
    private var _Background: some View {
        ZStack {
            Color.black
            Group {
                ColorfulView()
                
                if let outputImage = cameraManager.capturedPhoto?.image {
                    Image(uiImage: outputImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Image(returnImage())
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
            }
            
            .frame(homeVM.screen.size)
        }
    }
    
    private func returnImage() -> String {
        if let moment = userMomentsStore.currentMoment {
            return moment.url
        } else {
            return ""
        }
    }
    
}
