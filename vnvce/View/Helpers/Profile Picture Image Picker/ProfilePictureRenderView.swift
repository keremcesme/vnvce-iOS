
import SwiftUI
import PureSwiftUI

struct ProfilePictureRenderView: View {
    
    var image: UIImage
    var offset: CGSize
    var scale: CGFloat
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(size)
        }
        .scaleEffect(scale)
        .offset(offset.x, offset.y)
        .frame(width: 300, height: 300)
    }
}
