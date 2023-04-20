
import SwiftUI
import Introspect
import PureSwiftUI

struct UserProfileView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject public var userVM: UserProfileViewModel
    
    @State public var yOffset: CGFloat = 0
    
    public init(_ user: User.Public, profilePictureImage: UIImage?) {
        self._userVM = StateObject(wrappedValue: UserProfileViewModel(user, profilePictureImage: profilePictureImage))
    }
    
    private func yOffsetTask(_ value: CGFloat) {
        self.yOffset = value - UIDevice.current.statusAndNavigationBarHeight
    }
    
    var body: some View {
        ZStack {
            Background
            VStack(spacing:0) {
                Divider()
                    .opacity(-yOffset / 10)
                ScrollView {
                    VStack(spacing: 15) {
                        ProfilePicture
                        VStack(spacing: 5) {
                            DisplayName
                            Username
                        }
                        
                        RelationshipButton(userVM)

                    }
                    .padding(.top, 15)
                    .offsetY(yOffsetTask)
                }
                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar(ToolBar)
        .task {
            await userVM.fetchRelationship()
        }
    }
    
    @ViewBuilder
    private var DisplayName: some View {
        if let displayName = userVM.user.displayName {
            Text(displayName)
                .foregroundColor(.white)
                .font(.system(size: 24, weight: .bold, design: .default))
        }
    }
    
    @ViewBuilder
    private var Username: some View {
        Text(userVM.user.username)
            .foregroundColor(.secondary)
            .font(.system(size: 16, weight: .regular, design: .default))
    }
    
    @ViewBuilder
    private var Background: some View {
        BlurView(style: .systemMaterialDark)
            .background(_Background)
            .overlay(.black.opacity(0.5))
            .cornerRadius(UIDevice.current.screenCornerRadius, corners: [.topLeft, .bottomLeft])
            .ignoresSafeArea()
    }
    
    @ViewBuilder
    private var _Background: some View {
        ZStack {
            Color.black
            if let uiImage = userVM.profilePictureImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(UIScreen.main.size)
                    .clipped()
                    .scaleEffect(0.95)
            }
            
        }
    }
    
}
