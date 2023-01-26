
import SwiftUI
import SwiftUIX
import PureSwiftUI
import Colorful

extension CameraViewUI {
    @ViewBuilder
    public var PermissionLayer: some View {
        switch camera.configurationStatus {
        case .permissionDenied, .permissionNotDetermined:
            ZStack {
                ColorfulView().overlay(BlurView(style: .dark))
                VStack(spacing: 15){
                    Group {
                        Text("Allow vnvce to access your camera")
                            .font(.system(size: 20, weight: .bold, design: .default))
                            .foregroundColor(.primary)
                        Text("This lets you share photos.")
                            .font(.system(size: 16, weight: .regular, design: .default))
                            .foregroundColor(.secondary)
                    }
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    
                    PermissionButton
                        .padding(.top, 40)
                }
            }
            .frame(camera.previewViewFrame())
            .clipShape(RoundedRectangle(25, style: .continuous))
            .colorScheme(.dark)
        default:
            EmptyView()
        }
    }
    
    private func permissionButton() {
        if camera.configurationStatus == .permissionNotDetermined {
            camera.requestCameraAccess()
        } else if camera.configurationStatus == .permissionDenied {
            camera.openSettings()
        }
    }
    
    @ViewBuilder
    private var PermissionButton: some View{
        Button(action: permissionButton) {
            Text(camera.configurationStatus.buttonTitle)
                .foregroundStyle(.linearGradient(
                    colors: [Color.init(hex: "53E6CA"), Color.init(hex: "6A3FFB")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing))
                .font(.system(size: 14, weight: .semibold, design: .default))
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
                .background(Capsule().fill(.white))
        }
    }
}
