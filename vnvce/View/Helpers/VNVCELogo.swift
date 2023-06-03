
import SwiftUI
import PureSwiftUI

final class VNVCELogo {
    struct TextAndLogo: View {
        var body: some View {
            HStack {
                Group {
                    if UIDevice.current.hasNotch() {
                        Image("logo")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Image("logo")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .preferredColorScheme(.light)
                    }
                }
                .frame(width: 24, height: 24)
                .yOffset(2)
                Text("vnvce")
                    .foregroundColor(UIDevice.current.hasNotch() ? .primary : .white)
                    .font(.system(size: 36, weight: .heavy, design: .default))
                    .yOffset(-2)
                Spacer()
            }
        }
    }
}
