
import SwiftUI
import PureSwiftUI

extension UserMomentsView {
    
    @ViewBuilder
    public var NavigationBar: some View {
        HStack {
            NavigationLink {
                EmptyView()
                    .clearBackground()
            } label: {
                HStack(spacing: 10){
                    ProfilePicture
                    Text(usersAndTheirMoments.owner.displayName!)
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .medium, design: .default))
                    Spacer()
                }
                .frame(height: momentsStore.navBarHeight)
            }

//            Button {
//                UIImpactFeedbackGenerator(style: .light).impactOccurred()
//            } label: {
//                HStack(spacing: 10){
//                    ProfilePicture
//                    Text(userWithMoments.owner.displayName!)
//                        .foregroundColor(.white)
//                        .font(.system(size: 16, weight: .medium, design: .default))
//                    Spacer()
//                }
//                .frame(height: momentsStore.navBarHeight)
//            }
//            .buttonStyle(.scaled(anchor: .leading))
            Spacer()
            Button {
                 
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(90))
                    .font(.system(size: 18, weight: .medium, design: .default))
            }
            .buttonStyle(.scaled)
            Button {
                homeVM.currentTab = "CAMERA"
                homeVM.bottomResetScroll()
            } label: {
                Image(systemName: "xmark")
                    .foregroundColor(.white)
                    .font(.system(size: 24, weight: .medium, design: .default))
            }
            .buttonStyle(.scaled)
        }
        .padding(.horizontal, 20)
        .padding(.top, !UIDevice.current.hasNotch() ? UIDevice.current.statusBarHeight() + 4 : 0)
    }
    
    struct TestUser: View {
        var body: some View {
            ZStack {
                Color.red
                Text("ahfjkasdgfdjag")
            }
            .navigationBarHidden(true)
        }
    }
    
    @ViewBuilder
    private var ProfilePicture: some View {
        ZStack {
            Group {
                Image(usersAndTheirMoments.owner.profilePictureURL!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(momentsStore.navBarHeight - 1)
                BlurView(style: .dark)
                    .frame(momentsStore.navBarHeight)
                Image(usersAndTheirMoments.owner.profilePictureURL!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(momentsStore.navBarHeight - 5)
            }
            .clipShape(Circle())
        }
    }
}
