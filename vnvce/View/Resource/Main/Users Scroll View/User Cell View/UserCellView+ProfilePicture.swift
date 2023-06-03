
import SwiftUI
import PureSwiftUI

extension MainView.UserCellView {
    @ViewBuilder
    public var ProfilePicture: some View {
        ZStack(content: ZStackContent)
    }
    
    @ViewBuilder
    private func ZStackContent() -> some View {
        Group(content: ZStackContentGroup)
            .clipShape(Circle())
    }
    
    @ViewBuilder
    private func ZStackContentGroup() -> some View {
        if let image = profilePictureManager.image {
            Picture(image)
        } else {
            EmptyProfilePicture
        }
    }
    
    @ViewBuilder
    private func Picture(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(homeVM.cell.backgroundImageSize)
        BlurView(style: .regular)
            .frame(homeVM.cell.blurSize)
        Color.primary
            .opacity(0.1)
            .frame(homeVM.cell.imageSize)
            .overlay {
                Image(systemName: "play.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 28, weight: .medium, design: .default))
                    .scaleEffect(isSelected ? 1 : 0.00001)
            }
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(homeVM.cell.imageSize)
            .opacity(isSelected ? 0.00001 : 1)
    }
    
    @ViewBuilder
    private var EmptyProfilePicture: some View {
        Circle()
            .fill(.primary.opacity(0.1))
            .frame(homeVM.cell.size)
    }
    
}
