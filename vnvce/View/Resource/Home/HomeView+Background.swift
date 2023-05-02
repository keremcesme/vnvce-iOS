
import SwiftUI
import PureSwiftUI
import Colorful

extension HomeView {
    
    @ViewBuilder
    public var Background: some View {
        BlurView(style: .systemMaterialDark)
            .background(_Background)
//            .overlay(.black.opacity(homeVM.tab == homeVM.cameraRaw && !cameraManager.outputDidShowed ? 1 : 0.5))
            .overlay(.black.opacity(0.5))
            .animation(.default, value: homeVM.tab)
            .animation(.default, value: userMomentsStore.currentMoment)
            .animation(.easeInOut, value: shareMomentVM.viewWillAppear)
            .ignoresSafeArea()
    }
    
    @ViewBuilder
    private var _Background: some View {
        ZStack {
            Color.black
            Group {
                ColorfulView()
                
                if let outputImage = cameraManager.capturedPhoto?.image, shareMomentVM.viewWillAppear {
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
            return moment.media.url
        } else {
            return ""
        }
    }
    
}
