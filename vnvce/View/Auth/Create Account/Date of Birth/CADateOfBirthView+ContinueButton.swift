
import SwiftUI

extension CADateOfBirthView {
    @ViewBuilder
    public var ContinueButton: some View {
        Button(action: continueButtonAction) {
            ZStack {
                RoundedRectangle(12, style: .continuous)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, maxHeight: 60, alignment: .center)
                Text("Continue")
                    .foregroundStyle(.linearGradient(
                        colors: [Color.init(hex: "53E6CA"), Color.init(hex: "6A3FFB")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing))
                    .font(.system(size: 22, weight: .semibold, design: .default))
            }
        }
        .padding(.bottom, 18)
        .background(UsernameNavigation)
    }
    
    // Navigation Link
    private var UsernameNavigation: some View {
        NavigationLink(isActive: $authVM.showUsernameView) {
            CAUsernameView()
        } label: {
            EmptyView()
        }
        .isDetailLink(false)
    }
}
