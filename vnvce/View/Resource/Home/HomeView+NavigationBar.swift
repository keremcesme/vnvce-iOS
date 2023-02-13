
import SwiftUI
import Nuke
import NukeUI


extension HomeView {
    @ViewBuilder
    public var NavigationBar: some View {
        GeometryReader(alignment: .trailing, content: NavigationBar)
            .frame(height: homeVM.navBarHeight)
            .padding(.horizontal, 20)
            .padding(.top, !UIDevice.current.hasNotch() ? UIDevice.current.statusBarHeight() + 4 : 0)
    }
    
    @ViewBuilder
    private func NavigationBar(_ proxy: GeometryProxy) -> some View {
        let height = proxy.size.height
        HStack(spacing: 15){
            AddFriendButton(height)
            ProfileButton(height)
        }
    }
    
    @ViewBuilder
    private func AddFriendButton(_ height: CGFloat) -> some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            self.homeVM.showSearchView = true
            self.cameraManager.stopSession()
        } label: {
            Circle()
                .fill(.ultraThinMaterial)
                .colorScheme(.dark)
                .frame(width: height, height: height)
                .overlay {
                    Image(systemName: "person.badge.plus")
                        .foregroundColor(.white).opacity(0.65)
                        .font(.system(size: 18, weight: .medium, design: .default))
                }
        }
        .buttonStyle(ScaledButtonStyle())
        .fullScreenCover(isPresented: $homeVM.showSearchView) {
            SearchView()
                .clearBackground()
                .environmentObject(searchVM)
                .environmentObject(contactsVM)
                
        }
    }
    
    @ViewBuilder
    private func ProfileButton(_ height: CGFloat) -> some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            self.homeVM.showProfileView = true
            self.cameraManager.stopSession()
        } label: {
            if let url = currentUserVM.user?.profilePictureURL {
                LazyImage(url: URL(string: url)) { state in
                    if let uiImage = state.imageContainer?.image {
                        ZStack {
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
                                    .frame(width: height - 5, height: height - 5)
                            }
                            .clipShape(Circle())
                        }
                    } else {
                        EmptyProfilePicture(height)
                    }
                }
                .pipeline(.shared)
                .processors([ImageProcessors.Resize(width: height)])
                .priority(.veryHigh)
            } else {
                EmptyProfilePicture(height)
            }
        }
        .fullScreenCover(isPresented: $homeVM.showProfileView) {
            ProfileView()
                .clearBackground()
                .environmentObject(currentUserVM)
        }
    }
    
    @ViewBuilder
    private func EmptyProfilePicture(_ height: CGFloat) -> some View {
        Circle()
            .fill(.ultraThinMaterial)
            .colorScheme(.dark)
            .frame(width: height, height: height)
            .overlay {
                Image(systemName: "person.crop.circle")
                    .foregroundColor(.white).opacity(0.65)
                    .font(.system(size: height - 10, weight: .light, design: .default))
            }
    }
}

