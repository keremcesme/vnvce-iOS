
import SwiftUI
import SwiftUIX
import PureSwiftUI
import VNVCECore

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
    @EnvironmentObject public var appState: AppState
    
    @EnvironmentObject public var homeVM: HomeViewModel
    @EnvironmentObject public var cameraManager: CameraManager
    
    @EnvironmentObject public var momentsStore: UserMomentsStore
    @EnvironmentObject public var currentUserVM: CurrentUserViewModel
    
    @EnvironmentObject public var keyboardController: KeyboardController

    @StateObject public var locationManager = LocationManager()
    @StateObject public var shareMomentVM: ShareMomentViewModel
    
    @StateObject public var textHelper = TextHelper()
    
    init(_ capturedPhoto: CapturedPhoto) {
        self._shareMomentVM = StateObject(wrappedValue: .init(capturedPhoto))
    }
    
    private func commonInit() {
        shareMomentVM.viewWillAppear = true
//        locationManager.uploadTask = shareMomentVM.upload
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
        .taskInit(commonInit)
    }
}
