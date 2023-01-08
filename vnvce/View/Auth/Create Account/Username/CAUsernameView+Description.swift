
import SwiftUI

extension CAUsernameView {
    public var Description: some View {
        Text("Choose a unique username for yourself so your friends can find you. You can change it later whenever you want.")
            .foregroundColor(.secondary)
            .font(.system(size: 12, weight: .regular, design: .default))
            .multilineTextAlignment(.leading)
    }
}
