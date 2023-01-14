
import SwiftUI

struct CAVerifyPhoneNumberView: View {
    @Environment(\.colorScheme) var colorScheme
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
    
    private func createAccount() {
        hideKeyboard()
        authVM.createAccount()
    }
    
    var body: some View {
        ZStack(alignment: .top, content: BodyView)
            .navigationTitle("Verify Phone")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden(true)
            .toolbar(ToolBar)
            .taskInit(timerInit)
            .fullScreenCover(isPresented: $authVM.showDisplayNameView) {
                CADisplayNameView().environmentObject(authVM)
            }
    }
    
    @ViewBuilder
    private func BodyView() -> some View {
        ColorfulBackgroundView()
        VStack(alignment: .leading, spacing: 10) {
            Description
            OTPField
            CreateButton
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 18)
    }
    
    @ViewBuilder
    private var Description: some View {
        Text("Enter the code sent to \"+\(authVM.createPhoneNumber.countryCode) \(authVM.createPhoneNumber.nationalNumber)\".")
            .foregroundColor(.secondary)
            .font(.system(size: 12, weight: .regular, design: .default))
            .multilineTextAlignment(.leading)
        VStack(alignment: .leading, spacing: 5) {
            Text("Didn't get the code?")
                .foregroundColor(.secondary)
                .font(.system(size: 12, weight: .regular, design: .default))
            if timer.remaining > 0 {
                Text("You can request a new code after \(timer.remaining) seconds.")
                    .foregroundColor(Color.secondary)
                    .font(.system(size: 10, weight: .regular, design: .default))
            } else {
                
            }
        }
    }
    
    @ViewBuilder
    private var CreateButton: some View {
        Button(action: createAccount) {
            ZStack {
                RoundedRectangle(12, style: .continuous)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, maxHeight: 60, alignment: .center)
                    .opacity(buttonDisabled() ? 0.1 : 1)
                if !authVM.createAccountIsRunning {
                    ButtonText
                } else {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.secondary)
                }
            }
            
        }
        .disabled(buttonDisabled())
        .padding(.bottom, 18)

    }
    
    private func buttonDisabled() -> Bool {
        if !authVM.showCreateAccountButton || authVM.createAccountIsRunning {
            return true
        } else {
            return false
        }
    }
    
    @ViewBuilder
    private var ButtonText: some View {
        let text = "Create Account"
        Group {
            if authVM.showCreateAccountButton {
                Text(text)
                    .foregroundStyle(.linearGradient(
                        colors: [Color.init(hex: "53E6CA"), Color.init(hex: "6A3FFB")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing))
            } else {
                Text(text)
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                    .opacity(0.4)
            }
        }
        .font(.system(size: 22, weight: .semibold, design: .default))
    }
}
