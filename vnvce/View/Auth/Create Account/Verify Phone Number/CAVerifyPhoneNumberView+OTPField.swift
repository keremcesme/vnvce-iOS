
import SwiftUI

extension CAVerifyPhoneNumberView {
    
    @ViewBuilder
    public var OTPField: some View {
        HStack(spacing:0) {
            ForEach(0..<6, id: \.self, content: OTPTextBox)
        }
        .background {
            TextField("", text: $authVM.createOTPText.limit(6))
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .frame(width: 1, height: 1)
                .opacity(0.001)
                .blendMode(.screen)
                .focused($isKeyboardShowing)
                .onChange(of: authVM.createOTPText, perform: authVM.onChangeCreateAccountButton)
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
        .onAppear{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                isKeyboardShowing = true
            }
        }
    }
    
    @ViewBuilder
    private func OTPTextBox(_ index: Int) -> some View {
        ZStack {
            if authVM.createOTPText.count > index {
                let otpText = authVM.createOTPText
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
                    authVM.createOTPText.count > index ? .mint : .gray,
                    lineWidth: authVM.createOTPText.count > index ? 1 : 0.5
                )
        }
        .frame(maxWidth: .infinity)
        
    }
}
