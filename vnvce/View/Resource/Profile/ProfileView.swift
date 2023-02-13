
import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) public var dismiss
    
    @EnvironmentObject private var homeVM: HomeViewModel
    @EnvironmentObject public var currentUserVM: CurrentUserViewModel
    
    @State public var showProfilePictureAction: Bool = false
    @State public var currentImageIsDeleting: Bool = false
    @State public var showImagePicker: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top, content: BodyView)
                .clearBackground()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(Toolbar)
        }
        .cornerRadius(UIDevice.current.screenCornerRadius, corners: [.topLeft, .topRight])
        .ignoresSafeArea()
        .colorScheme(.dark)
    }
    
    @ViewBuilder
    private func BodyView() -> some View {
        Background
        VStack(spacing:0) {
            Divider()
            ScrollView {
                VStack(spacing: 15) {
                    ProfilePicture
                }
                .padding(.top, 15)
            }
            Spacer()
        }
        .fullScreenCover(isPresented: $showImagePicker) {
            ProfilePictureImagePicker()
                .clearBackground()
                .environmentObject(currentUserVM)
        }
    }
    
    
    @ViewBuilder
    private var Background: some View {
        BlurView(style: .systemMaterialDark)
            .overlay(.black.opacity(0.2))
            .ignoresSafeArea()
    }
    
}

extension ProfileView {
    @ToolbarContentBuilder
    public var Toolbar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) { DismissButton }
        ToolbarItem(placement: .principal) { Title }
        
    }
    
    @ViewBuilder
    private var Title: some View {
        Text(currentUserVM.user?.username.username ?? "")
            .font(.system(size: 16, weight: .semibold, design: .default))
            .frame(width: 150, alignment: .center)
    }
    
    @ViewBuilder
    private var DismissButton: some View {
        Button(action: dismiss) {
            Image(systemName: "chevron.down")
                .foregroundColor(.white)
                .font(.system(size: 18, weight: .semibold, design: .default))
                .contentShape(Rectangle())
        }
        .buttonStyle(ScaledButtonStyle())
    }
}
