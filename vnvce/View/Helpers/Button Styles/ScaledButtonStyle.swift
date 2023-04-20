
import SwiftUI

struct ScaledButtonStyle: ButtonStyle {
    private var anchor: UnitPoint
    
    public init(anchor: UnitPoint = .center) {
        self.anchor = anchor
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1, anchor: anchor)
            .offset(y: configuration.isPressed ? 2 : 0)
            .opacity(configuration.isPressed ? 0.94 : 1)
            .animation(.easeInOut(duration: 0.21), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == ScaledButtonStyle {
  static var scaled: ScaledButtonStyle { .init() }
    
    static func scaled(anchor: UnitPoint) -> ScaledButtonStyle {
        .init(anchor: anchor)
    }
}
