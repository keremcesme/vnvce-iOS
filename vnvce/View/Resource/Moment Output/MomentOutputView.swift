
import SwiftUI
import SwiftUIX
import PureSwiftUI

struct MomentOutputViewRoot: View {
    @EnvironmentObject public var cameraManager: CameraManager
    
    var body: some View {
        ZStack {
            if cameraManager.outputWillShowed {
                Color.black.opacity(0.000001)
                    .ignoresSafeArea()
            }
            if let capturedPhoto = cameraManager.capturedPhoto {
                MomentOutputView(capturedPhoto)
            }
        }
        
    }
}

struct MomentOutputView: View {
    @EnvironmentObject public var homeVM: HomeViewModel
    @EnvironmentObject public var cameraManager: CameraManager
    @EnvironmentObject public var momentsStore: UserMomentsStore
    
    @EnvironmentObject public var shareMomentVM: ShareMomentViewModel
    @EnvironmentObject public var keyboardController: KeyboardController
    
    @StateObject public var textHelper = TextHelper()
    
    public var capturedPhoto: CapturedPhoto
    
    init(_ capturedPhoto: CapturedPhoto) {
        self.capturedPhoto = capturedPhoto
    }
    
    var body: some View {
        GeometryReader { g in
            ZStack {
                if UIDevice.current.hasNotch() {
                    VStack(spacing:10) {
                        NavigationBar.zIndex(1)
                        VStack(spacing:10) {
                            ImageView.zIndex(0)
                            ShareButton.zIndex(2)
                        }
                        .overlay {
                            if shareMomentVM.showAudienceSheet {
                                Color.black.opacity(0.5)
                                    .frame(UIScreen.main.bounds.size)
                                    .ignoresSafeArea()
                                    .onTapGesture {
                                        shareMomentVM.showAudienceSheet = false
                                    }
                            }
                        }
                        Spacer()
                    }
                }
            }
        }
        .animation(.easeInOut, value: shareMomentVM.showAudienceSheet)
        .animation(.easeInOut(duration: keyboardController.duration), value: keyboardController.isShowed)
        .animation(.easeInOut, value: shareMomentVM.viewWillAppear)
        .animation(shareMomentVM.setAnimation(), value: shareMomentVM.viewWillDisappear)
        .taskInit(shareMomentVM.initView)
    }
}
