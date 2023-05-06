
import SwiftUI

// UNUSED
extension MomentOutputView {
    @ViewBuilder
    public var Background: some View {
//        if shareMomentVM.viewWillAppear  {
            BlurView(style: .systemMaterialDark)
                .background(_BackgroundImage)
                .background(Color.black)
                .overlay(.black.opacity(0.6))
                .ignoresSafeArea()
//        }
        
    }
    
    @ViewBuilder
    private var _BackgroundImage: some View {
//        if shareMomentVM.viewDidAppear {
        Image(uiImage: shareMomentVM.capturedPhoto.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(homeVM.screen.size)
//        }
    }
}
