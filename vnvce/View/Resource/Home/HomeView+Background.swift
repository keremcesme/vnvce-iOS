
import SwiftUI
import PureSwiftUI

extension HomeView {
    
    @ViewBuilder
    public var Background: some View {
        BlurView(style: .systemMaterialDark)
            .background(_Background)
            .overlay(.black.opacity(homeVM.tab == homeVM.cameraRaw ? 1 : 0.5))
            .animation(.default, value: homeVM.tab)
            .animation(.default, value: userMomentsStore.currentMoment)
            .ignoresSafeArea()
    }
    
    @ViewBuilder
    private var _Background: some View {
        ZStack {
            Color.black
            Image(returnImage())
                .resizable()
                .aspectRatio(contentMode: .fill)
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
