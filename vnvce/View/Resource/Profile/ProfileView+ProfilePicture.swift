
import SwiftUI
import Nuke
import NukeUI
import PureSwiftUI
import ActionOver

extension ProfileView {
    private func showImagePickerAction() {
        showImagePicker = true
    }
    
    private func deleteImageAction() {
        Task {
            currentImageIsDeleting = true
            guard let userID = currentUserVM.user?.id else {
                currentImageIsDeleting = false
                return
            }
            try await MeAPI().editProfilePicture(.init())
            try await StorageAPI().deleteProfilePicture(userID.uuidString.convertStorageName())
            await MainActor.run {
                currentUserVM.user?.profilePictureURL = nil
                currentImageIsDeleting = false
            }
        }
    }
    
    private var actionButtons: [ActionOverButton] {
        if currentUserVM.user?.profilePictureURL == nil {
            return [
                .init(title: "Choose from library", type: .normal, action: showImagePickerAction),
                .init(title: nil, type: .cancel, action: nil)
            ]
        } else {
            return [
                .init(title: "Choose from library", type: .normal, action: showImagePickerAction),
                .init(title: "Delete current picture", type: .destructive, action: deleteImageAction),
                .init(title: nil, type: .cancel, action: nil)
            ]
        }
    }
    
    @ViewBuilder
    public var ProfilePicture: some View {
        let height: CGFloat = 120
        
        if currentImageIsDeleting {
            UpdatedingProfilePicture(height)
        } else {
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                self.showProfilePictureAction = true
            } label: {
                let user = currentUserVM.user
                let displayName = user?.displayName
                if let url = user?.profilePictureURL {
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
            .buttonStyle(ScaledButtonStyle())
            .disabled(currentImageIsDeleting)
            .actionOver(isPresented: $showProfilePictureAction,
                        title: "Change your profile picture",
                        message: "Your profile picture is visible to everyone.",
                        buttons: actionButtons)
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
    
    @ViewBuilder
    private func UpdatedingProfilePicture( _ height: CGFloat) -> some View {
        ZStack {
            Group {
                Color.white.opacity(0.1)
                    .frame(height)
                Color.white.opacity(0.1)
                    .frame(height - 10)
            }
            .clipShape(Circle())
            
            ProgressView()
                .progressViewStyle(.circular)
                .tint(.secondary)
        }
    }
}
