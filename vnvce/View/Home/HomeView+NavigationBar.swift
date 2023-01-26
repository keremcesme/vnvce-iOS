
import SwiftUI

extension HomeView {
    @ViewBuilder
    public var NavigationBar: some View {
        GeometryReader(content: NavigationBar)
            .frame(height: homeVM.navBarHeight)
            .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private func NavigationBar(_ proxy: GeometryProxy) -> some View {
        let height = proxy.size.height
        HStack(spacing: 15){
            Spacer()
            AddFriendButton(height)
            ProfileButton(height)
        }
    }
    
    @ViewBuilder
    private func AddFriendButton(_ height: CGFloat) -> some View {
        Button {
            
        } label: {
            Circle()
                .fill(.ultraThinMaterial)
                .colorScheme(.dark)
//            BlurView(style: .systemThickMaterialDark)
                .frame(width: height, height: height)
//                .clipShape(Circle())
                .overlay {
                    Image(systemName: "person.badge.plus")
                        .foregroundColor(.white).opacity(0.9)
                        .font(.system(size: 18, weight: .medium, design: .default))
                }
        }
    }
    
    @ViewBuilder
    private func ProfileButton(_ height: CGFloat) -> some View {
        Button {
            
        } label: {
            ZStack {
                Group {
                    Image("me")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: height - 1, height: height - 1)
                    BlurView(style: .dark)
                        .frame(width: height, height: height)
                    Image("me")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: height - 5, height: height - 5)
                }
                .clipShape(Circle())
            }
            
        }
    }
}
