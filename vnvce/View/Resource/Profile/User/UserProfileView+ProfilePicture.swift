
import SwiftUI
import Nuke
import NukeUI
import PureSwiftUI

extension UserProfileView {
    
    @ViewBuilder
    public var ProfilePicture: some View {
        let height: CGFloat = 120
        
        let user = userVM.user
        let displayName = user.displayName
        if let url = user.profilePictureURL {
            LazyImage(url: URL(string: url)) { state in
                if let uiImage = state.imageContainer?.image {
                    Group {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: height - 1, height: height - 1)
                        BlurView(style: .dark)
                            .frame(width: height, height: height)
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: height - 10, height: height - 10)
                    }
                    .clipShape(Circle())
                    .taskInit {
                        self.userVM.profilePictureImage = uiImage
                    }
                } else {
                    EmptyProfilePicture(displayName, height)
                }
            }
            .processors([ImageProcessors.Resize(width: height)])
            .priority(.veryHigh)
        } else {
            EmptyProfilePicture(displayName, height)
        }
    }
    
    @ViewBuilder
    private func EmptyProfilePicture(_ displayName: String?, _ height: CGFloat) -> some View {
        ZStack {
            Group {
                Color.white.opacity(0.1)
                    .frame(height)
                Color.white.opacity(0.1)
                    .frame(height - 10)
            }
            .clipShape(Circle())
            
            if let displayName {
                Text(displayName[0])
                    .font(.system(size: 48, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(0.7)
            } else {
                Image(systemName: "person.crop.circle")
                    .font(.system(size: 58, weight: .light, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(0.75)
            }
        }
    }
    
}
