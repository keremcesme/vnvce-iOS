
import SwiftUI
import PureSwiftUI

extension MomentOutputView {
    private func shareButtonAction() {
        Task {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            
            if let location = locationManager.location,  shareMomentVM.selectedAudience == .nearby {
                await shareMomentVM.upload(location: .init(latitude: location.latitude, longitude: location.longitude), message: textHelper.text)
            } else {
                await shareMomentVM.upload(location: nil, message: textHelper.text)
            }
            
            homeVM.bottomResetScroll(animated: false)
            cameraManager.outputDidShowed = false
            await shareMomentVM.deinitView()
            cameraManager.capturedPhoto = nil
            momentsStore.currentMoment = nil
            cameraManager.outputWillShowed = false
            
        }
    }
    
    @ViewBuilder
    public var ShareButton: some View {
        Button(action: shareButtonAction) {
            BlurView(style: .systemUltraThinMaterialDark)
                .frame(80, 80)
                .clipShape(Circle())
                .overlay {
                    Image(systemName: "paperplane")
                        .foregroundColor(.white)
                        .font(.system(size: 32, weight: .medium, design: .default))
                }
        }
        .buttonStyle(.scaled)
        .padding(.top, 5)
        .opacity(shareMomentVM.viewWillAppear ? 1 : 0.0001)
        
    }
    
}
