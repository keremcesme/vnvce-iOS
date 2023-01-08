
import SwiftUI
import Colorful

struct ColorfulBackgroundView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ColorfulView()
            .overlay {
                BlurView(style: .regular)
                    .opacity(0.7)
                    .ignoresSafeArea()
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .onTapGesture(perform: hideKeyboard)
    }
}

