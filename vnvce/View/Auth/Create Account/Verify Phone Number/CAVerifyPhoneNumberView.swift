
import SwiftUI

struct CAVerifyPhoneNumberView: View {
    @Environment(\.dismiss) public var dismiss
    
    @EnvironmentObject public var authVM: AuthViewModel
    
    @StateObject public var timer = OTPTimerController()
    
    @FocusState public var isKeyboardShowing: Bool
    
    private func timerInit() {
        guard let otp = authVM.otp else {
            return
        }
        timer.commonInit(start: otp.createdAt, expire: otp.expireAt)
    }
    
    var body: some View {
        ZStack(alignment: .top, content: BodyView)
            .navigationTitle("Verify Phone")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden(true)
            .toolbar(ToolBar)
            .taskInit(timerInit)
    }
    
    @ViewBuilder
    private func BodyView() -> some View {
        ColorfulBackgroundView()
        VStack(alignment: .leading, spacing: 10) {
            Text("You can request a new code after \(timer.remaining) seconds.")
                .foregroundColor(Color.secondary)
                .font(.system(size: 10, weight: .regular, design: .default))
            OTPField
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 18)
    }
}
