
import SwiftUI
import ActionOver

extension View {
    func actionOver(isPresented: Binding<Bool>, title: String, message: String? = nil, buttons: [ActionOverButton]) -> some View {
        self.actionOver(presented: isPresented, title: title, message: message, buttons: buttons, ipadAndMacConfiguration: .init(anchor: nil, arrowEdge: nil))
            .colorScheme(.dark)
    }
}
