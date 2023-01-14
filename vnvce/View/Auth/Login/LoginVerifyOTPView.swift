
import SwiftUI

struct LoginVerifyOTPView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var authVM: AuthViewModel
    
    @StateObject public var timer = OTPTimerController()
    
    @FocusState public var isKeyboardShowing: Bool
    
    private func timerInit() {
        guard let otp = authVM.loginOTPResponse?.otp else {
            return
        }
        timer.commonInit(start: otp.createdAt, expire: otp.expireAt)
    }
    
    private func loginButton() {
        hideKeyboard()
        authVM.verifyOTPAndLogin()
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top, content: BodyView)
                .navigationTitle("Verify Phone")
                .navigationBarTitleDisplayMode(.large)
                .navigationBarBackButtonHidden(true)
                .toolbar(ToolBar)
                .taskInit(timerInit)
        }
    }
    
    @ViewBuilder
    private func BodyView() -> some View {
        ColorfulBackgroundView()
        VStack(alignment: .leading, spacing: 10) {
            Description
            OTPField
            LoginButton
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 18)
    }
    
    @ViewBuilder
    private var Description: some View {
        Text("Enter the code sent to \"+\(authVM.loginPhoneNumber.countryCode) \(authVM.loginPhoneNumber.nationalNumber)\".")
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
    public var OTPField: some View {
        HStack(spacing:0) {
            ForEach(0..<6, id: \.self, content: OTPTextBox)
        }
        .background {
            TextField("", text: $authVM.loginOTPText.limit(6))
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .frame(width: 1, height: 1)
                .opacity(0.001)
                .blendMode(.screen)
                .focused($isKeyboardShowing)
                .onChange(of: authVM.loginOTPText, perform: authVM.onChangeLoginButton)
        }
        .padding(15)
        .background {
            RoundedRectangle(12, style: .continuous)
                .foregroundColor(.primary)
                .opacity(0.05)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isKeyboardShowing.toggle()
        }
        .taskInit {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
//                isKeyboardShowing = true
            }
        }
    }
    
    @ViewBuilder
    private func OTPTextBox(_ index: Int) -> some View {
        ZStack {
            if authVM.loginOTPText.count > index {
                let otpText = authVM.loginOTPText
                let startIndex = otpText.startIndex
                let charIndex = otpText.index(startIndex, offsetBy: index)
                let charToString = String(otpText[charIndex])
                Text(charToString)
            } else {
                Text(" ")
            }
        }
        .frame(width: 45, height: 45)
        .background {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(
                    authVM.loginOTPText.count > index ? .mint : .gray,
                    lineWidth: authVM.loginOTPText.count > index ? 1 : 0.5
                )
        }
        .frame(maxWidth: .infinity)
        
    }
    
    @ViewBuilder
    private var LoginButton: some View {
        Button(action: loginButton) {
            ZStack {
                RoundedRectangle(12, style: .continuous)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, maxHeight: 60, alignment: .center)
                    .opacity(buttonDisabled() ? 0.1 : 1)
                if !authVM.loginVerifyOTPIsRunning {
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
        if !authVM.showLoginButton || authVM.loginVerifyOTPIsRunning {
            return true
        } else {
            return false
        }
    }
    
    @ViewBuilder
    private var ButtonText: some View {
        let text = "Login"
        Group {
            if authVM.showLoginButton {
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
    
    @ToolbarContentBuilder
    var ToolBar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) { BackButton }
        ToolbarItem(placement: .navigationBarTrailing) { ActivityIndicator }
    }
    
    @ViewBuilder
    private var BackButton: some View {
        Button(action: dismiss) {
            Image(systemName: "xmark")
                .font(.system(size: 18, weight: .medium, design: .default))
                .foregroundColor(authVM.loginVerifyOTPIsRunning ? .secondary : .primary)
        }
        .disabled(authVM.loginVerifyOTPIsRunning)
    }
    
    @ViewBuilder
    var ActivityIndicator: some View {
        if authVM.loginVerifyOTPIsRunning {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(.secondary)
        }
    }
}
