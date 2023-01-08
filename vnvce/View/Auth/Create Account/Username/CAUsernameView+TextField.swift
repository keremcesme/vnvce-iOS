
import SwiftUI

extension CAUsernameView {
    @ViewBuilder
    public var UsernameField: some View {
        HStack(spacing: 5) {
            Image(systemName: "person.fill")
                .foregroundColor(authVM.username.isEmpty ? .secondary :
                        .primary)
                .font(.system(size: 18, weight: .medium, design: .default))
                .frame(width: 18, height: 18, alignment: .center)
            TextField("Username", text: $authVM.username)
                .font(.system(size: 22, weight: .bold))
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .submitLabel(.done)
                .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: 60, alignment: .center)
                .onChange(of: authVM.username) {
                    authVM.usernameAvailability = .nothing
                    authVM.checkUsernameIsRunning = !$0.isEmpty
                }
                .onChange(of: authVM.usernameAvailability) { value in
                    authVM.onChangeUsernameContinueButton(value)
                }
                .onReceive(authVM.$username.debounce(for: 0.8, scheduler: RunLoop.main)) { _ in
                    authVM.checkUsername()
                }
            switch authVM.usernameAvailability {
            case .available:
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.green)
            case .unavailable:
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.red)
            default:
                if authVM.checkUsernameIsRunning {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .secondary))
                }
            }
        }
        .padding(.horizontal, 15)
        .background {
            RoundedRectangle(12, style: .continuous)
                .foregroundColor(.primary)
                .opacity(0.05)
        }
    }
}
