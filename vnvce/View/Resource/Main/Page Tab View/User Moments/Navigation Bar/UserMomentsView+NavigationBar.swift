
import SwiftUI
import PureSwiftUI
import SDWebImageSwiftUI

extension UserMomentsView.MomentView {
    
    struct NavigationBar: View {
        @EnvironmentObject public var homeVM: HomeViewModel
        
        @StateObject public var profilePictureManager = ImageManager()
        @Binding public var vm: UserAndTheirMoments
        
        public init(_ vm: Binding<UserAndTheirMoments>) {
            self._vm = vm
        }
        
        private func downloadProfilePicture() {
            profilePictureManager.cacheType = .disk
            if profilePictureManager.image == nil {
                let url: URL? = URL(string: vm.user.detail.profilePictureURL! + ",sig=\(1)")
                profilePictureManager.load(url: url)
            }
        }
        
        var body: some View {
            HStack(spacing: 20, content: HStackContent)
                .padding(.horizontal, 20)
                .padding(.top, !UIDevice.current.hasNotch() ? UIDevice.current.statusBarHeight() + 4 : 0)
                .onAppear(perform: downloadProfilePicture)
        }
        
        @ViewBuilder
        private func HStackContent() -> some View {
            ProfileButton
            Spacer()
            EllipsisButton
            DismissButton
        }
    }
}

// MARK: Ellipsis Button -
extension UserMomentsView.MomentView.NavigationBar {
    
    private func ellipsisButtonAction() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    
    @ViewBuilder
    private var EllipsisButton: some View {
        Button(action: ellipsisButtonAction, label: EllipsisButtonContent)
            .buttonStyle(.scaled)
    }
    
    @ViewBuilder
    private func EllipsisButtonContent() -> some View {
        Image(systemName: "ellipsis")
            .foregroundColor(.primary)
            .opacity(0.85)
            .rotationEffect(.degrees(90))
            .font(.system(size: 18, weight: .medium, design: .default))
            .contentShape(Rectangle())
    }
}
// MARK: -

// MARK: Dismiss Button -
extension UserMomentsView.MomentView.NavigationBar {
    private func dismissButtonAction() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        homeVM.currentTab = "CAMERA"
    }
    
    @ViewBuilder
    private var DismissButton: some View {
        Button(action: dismissButtonAction, label: DismissButtonLabel)
            .buttonStyle(.scaled)
    }
    
    @ViewBuilder
    private func DismissButtonLabel() -> some View {
        Image(systemName: "xmark")
            .foregroundColor(.primary)
            .opacity(0.85)
            .font(.system(size: 24, weight: .medium, design: .default))
            .contentShape(Rectangle())
    }
}
// MARK: -
