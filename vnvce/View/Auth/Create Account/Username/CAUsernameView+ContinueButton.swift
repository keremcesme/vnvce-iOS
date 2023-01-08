
import SwiftUI

extension CAUsernameView {
    @ViewBuilder
    public var ContinueButton: some View {
        Button(action: continueButton) {
            ZStack {
                RoundedRectangle(12, style: .continuous)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, maxHeight: 60, alignment: .center)
                    .opacity(buttonDisabled() ? 0.1 : 1)
                if !authVM.reserveUsernameSendOTPIsRunning {
                    ButtonText
                } else {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.secondary)
                }
            }
        }
        .disabled(buttonDisabled())
        .background(VerifyPhoneNumberNavigation)
        .padding(.bottom, 18)
    }
    
    private func buttonDisabled() -> Bool {
        if !authVM.showUsernameContinueButton || authVM.reserveUsernameSendOTPIsRunning {
            return true
        } else {
            return false
        }
    }
    
    @ViewBuilder
    private var ButtonText: some View {
        let text = "Continue"
        Group {
            if authVM.showUsernameContinueButton {
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
    
    // Navigation Link
    private var VerifyPhoneNumberNavigation: some View {
        NavigationLink(isActive: $authVM.showCreateOTPVerifyView) {
            CAVerifyPhoneNumberView()
        } label: {
            EmptyView()
        }
        .isDetailLink(false)
    }
}
