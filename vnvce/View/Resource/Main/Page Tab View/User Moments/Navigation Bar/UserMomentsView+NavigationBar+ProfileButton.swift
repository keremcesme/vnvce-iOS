
import SwiftUI
import SwiftUIX

extension UserMomentsView.MomentView.NavigationBar {
    private func profileButtonAction() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    // MARK: Button -
    @ViewBuilder
    public var ProfileButton: some View {
        Button(action: profileButtonAction, label: ButtonLabel)
            .buttonStyle(.scaled)
    }
    
    @ViewBuilder
    private func ButtonLabel() -> some View {
        HStack(spacing: 10, content: ButtonLabelContent)
            .frame(height: homeVM.navBarHeight)
            .contentShape(Rectangle())
    }
    
    @ViewBuilder
    private func ButtonLabelContent() -> some View {
        ProfilePicture
        DisplayName
    }
    // MARK: -
    
    // MARK: Profile Picture -
    @ViewBuilder
    private var ProfilePicture: some View {
        ZStack(content: ProfilePictureContent)
    }
    
    @ViewBuilder
    private func ProfilePictureContent() -> some View {
        Group(content: ProfilePictureContentGroup)
            .clipShape(Circle())
    }
    
    @ViewBuilder
    private func ProfilePictureContentGroup() -> some View {
        if let image = profilePictureManager.image {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(homeVM.navBarHeight - 1)
            BlurView(style: UIDevice.current.hasNotch() ? .regular : .dark)
                .frame(homeVM.navBarHeight)
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(homeVM.navBarHeight - 5)
        } else {
            Circle()
                .foregroundColor(UIDevice.current.hasNotch() ? .primary : .white)
                .opacity(0.1)
                .frame(homeVM.navBarHeight)
                .shimmering()
        }
    }
    // MARK: -
    
    // MARK: Display Name -
    private var returnDisplayName: String {
        if let displayName = vm.user.detail.displayName {
            return displayName
        } else {
            return vm.user.detail.username
        }
    }
    @ViewBuilder
    private var DisplayName: some View {
        Text(returnDisplayName)
            .foregroundColor(UIDevice.current.hasNotch() ? .primary : .white)
            .opacity(0.85)
            .font(.system(size: 16, weight: .semibold, design: .default))
    }
    // MARK: -
}
