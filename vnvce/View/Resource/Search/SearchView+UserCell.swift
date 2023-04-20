
import SwiftUI
import SwiftUIX
import Nuke
import NukeUI

extension SearchView {
    struct UserCellView: View {
        private let profilePictureHeight: CGFloat = 60
        private let user: User.Public
        
        @State private var showUser: Bool = false
        
        @State private var profilePictureImage: UIImage?
        
        public init(_ user: User.Public) {
            self.user = user
        }
        
        private func action() {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            showUser = true
        }
        
        var body: some View {
            Button(action: action) {
                HStack(spacing: 10) {
                    ZStack {
                        if let url = user.profilePictureURL {
                            LazyImage(url: URL(string: url)) { state in
                                if let uiImage = state.imageContainer?.image {
                                    ProfilePicture(uiImage)
                                        .taskInit {
                                            self.profilePictureImage = uiImage
                                        }
                                } else {
                                    EmptyProfilePicture
                                }
                            }
                            .pipeline(.shared)
                            .processors([ImageProcessors.Resize(width: profilePictureHeight)])
                        } else {
                            EmptyProfilePicture
                        }
                    }
                    DisplayNameAndUsername
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.system(size: 13, weight: .semibold, design: .default))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(ScaledButtonStyle())
            .background {
                NavigationLink(isActive: $showUser) {
                    UserProfileView(user, profilePictureImage: profilePictureImage)
                        .clearBackground()
                } label: { EmptyView() }
                .isDetailLink(true)
            }
//            .navigationDestination(isPresented: $showUser) {
//                UserProfileView(user)
//            }
        }
        
        @ViewBuilder
        private var DisplayNameAndUsername: some View {
            VStack(alignment: .leading, spacing: 2.5) {
                if let displayName = user.displayName {
                    Text(displayName)
                        .font(.system(size: 16, weight: .semibold, design: .default))
                        .foregroundColor(.white)
                    Text(user.username)
                        .font(.system(size: 14, weight: .regular, design: .default))
                        .foregroundColor(.secondary)
                } else {
                    Text(user.username)
                        .font(.system(size: 16, weight: .semibold, design: .default))
                        .foregroundColor(.white)
                }
                
            }
        }
        
        @ViewBuilder
        private func ProfilePicture(_ uiImage: UIImage) -> some View {
            ZStack {
                Group {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(profilePictureHeight - 1)
                    BlurView(style: .dark)
                        .frame(profilePictureHeight)
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(profilePictureHeight - 8)
                }
                .clipShape(Circle())
            }
        }
        
        @ViewBuilder
        private var EmptyProfilePicture: some View {
            ZStack {
                Group {
                    Color.white.opacity(0.1)
                        .frame(profilePictureHeight)
                    Color.white.opacity(0.1)
                        .frame(profilePictureHeight - 8)
                }
                .clipShape(Circle())
                if let displayName = user.displayName {
                    Text(displayName[0])
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(0.7)
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(0.75)
                }
            }
        }
        
        
    }
   
}


