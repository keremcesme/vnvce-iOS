
import SwiftUI

struct ScaledButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .offset(y: configuration.isPressed ? 2 : 0)
            .opacity(configuration.isPressed ? 0.94 : 1)
            .animation(.easeInOut(duration: 0.21), value: configuration.isPressed)
    }
}
