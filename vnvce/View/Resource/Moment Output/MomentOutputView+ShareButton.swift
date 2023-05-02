
import SwiftUI
import PureSwiftUI

extension MomentOutputView {
    @ViewBuilder
    public var ShareButton: some View {
        Button {
            
            Task {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                homeVM.bottomResetScroll(animated: false)
                cameraManager.outputDidShowed = false
                await shareMomentVM.deinitView()
                cameraManager.capturedPhoto = nil
                momentsStore.currentMoment = nil
                cameraManager.outputWillShowed = false
                
            }
        } label: {
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
