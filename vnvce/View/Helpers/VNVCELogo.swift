
import SwiftUI
import PureSwiftUI

final class VNVCELogo {
    struct TextAndLogo: View {
        var body: some View {
            HStack {
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 24, height: 24)
                    .yOffset(2)
                Text("vnvce")
                    .foregroundColor(.white)
                    .font(.system(size: 36, weight: .heavy, design: .default))
                    .yOffset(-2)
                Spacer()
            }
            .colorScheme(.dark)
        }
    }
}
