
import SwiftUI
import PureSwiftUI

enum CropOrientation {
    case square
    case landscape
    case portrait
}

struct ProfilePictureCropView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var gestureController = ProfilePictureCropGestureController()
    
    private let screen = UIScreen.main.bounds
    
    @State private var isInteracting: Bool = false
    
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    
    @State private var renderSize: CGSize = .zero
    @State private var renderRect: CGRect = .zero
    
    @State var orientation: CropOrientation
    
    let image: UIImage
    
    init(image: UIImage) {
        self.image = image
        
        let size = image.size
        
        if size.width > size.height {
            self.orientation = .landscape
        } else if size.width < size.height {
            self.orientation = .portrait
        } else {
            self.orientation = .square
        }
    }
    
    func render() {
        let image = self.image.cropsToSquare2(rect: self.renderRect, size: self.renderSize)
            .resized(toWidth: 300)!
        
        ImageSaver().writeToPhotoAlbum(image: image)
        
        
    }
    
    var body: some View {
        ZStack {
            Background
            CropArea.overlay(MaskView)
            GestureView(isInteracting: $isInteracting, offset: $offset, lastOffset: $lastOffset, scale: $scale, lastScale: $lastScale)
            VStack {
                Spacer()
                Button {
                    self.render()
                } label: {
                    Text("Render")
                        .padding()
                        .contentShape(Rectangle())
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(Toolbar)
        .ignoresSafeArea()
        
    }
    
    @ViewBuilder
    private var CropArea: some View {
        let width = UIScreen.main.bounds.width - 29
        GeometryReader {
            let size = $0.size
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .overlay { GestureOnEndOverlay(size) }
                .frame(size)
        }
        .scaleEffect(scale)
        .offset(offset.x, offset.y)
        .coordinateSpace(name: "CROP_VIEW")
        .frame(width: width, height: width)
    }
    
    private func haptic() {
        if !isInteracting {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
    
    @ViewBuilder
    private func GestureOnEndOverlay(_ size: CGSize) -> some View {
        GeometryReader {
            let rect = $0.frame(in: .named("CROP_VIEW"))
            let absSize = $0.size
            Color.clear
                .taskInit {
                    self.renderRect = rect
                    self.renderSize = absSize
                }
                .onChange(of: offset) { _ in
//                    print(rect)
                }
                .onChange(of: isInteracting) { value in
                    DispatchQueue.main.async {
                        if !value {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                if rect.minX > 0 {
                                    offset.width = (offset.width - rect.minX)
                                    haptic()
                                }
                                
                                if rect.minY > 0 {
                                    offset.height = (offset.height - rect.minY)
                                    haptic()
                                }
                                
                                if rect.maxX < size.width {
                                    offset.width = (rect.minX - offset.width)
                                    haptic()
                                }
                                
                                if rect.maxY < size.height {
                                    offset.height = (rect.minY - offset.height)
                                    haptic()
                                }
                            }
                            
                            lastOffset = offset
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                self.renderRect = rect
                                self.renderSize = absSize
                            }
                            
                        }
                    }
                    
                }
        }
    }
    
    @ViewBuilder
    private var Background: some View {
        BlurView(style: .systemMaterialDark)
            .background {
                ZStack {
                    Color.black
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(UIScreen.main.bounds.size)
                }
            }
    }
}

extension ProfilePictureCropView {
    @ViewBuilder
    private var MaskView: some View {
        Group {
            if isInteracting {
                Rectangle()
                    .fill(Color.black).opacity(0.65)
            } else {
                BlurView(style: .dark)
                    .background{
                        Rectangle()
                            .fill(Color.black).opacity(0.65)
                    }
            }
        }
        .mask(CircleMask().fill(style: FillStyle(eoFill: true)))
        .frame(UIScreen.main.bounds.size)
        .animation(.default, value: isInteracting)
    }
    
    private func CircleMask() -> Path {
        let rect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        let insetRect = CGRect(x: 15, y: 15, width: UIScreen.main.bounds.width - ( 15 * 2 ), height: UIScreen.main.bounds.height - ( 15 * 2 ))
        var shape = Rectangle().path(in: rect)
        shape.addPath(Circle().path(in: insetRect))
        return shape
    }
}

extension ProfilePictureCropView {
    @ToolbarContentBuilder
    public var Toolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) { BackButton }
    }
    
    @ViewBuilder
    private var BackButton: some View {
        Button(action: dismiss) {
            Image(systemName: "chevron.backward")
                .foregroundColor(.white)
                .font(.system(size: 18, weight: .semibold, design: .default))
                .contentShape(Rectangle())
        }
    }
}

extension UIImage {
    func cropsToSquare(offset: CGSize, scale: CGFloat) -> UIImage {
        let refWidth = CGFloat((self.cgImage!.width))
        let refHeight = CGFloat((self.cgImage!.height))
        let cropSize = refWidth > refHeight ? refHeight : refWidth
        
        var x = (refWidth - cropSize) / 2.0
        var y = (refHeight - cropSize) / 2.0
        
        let ratio = -cropSize / (UIScreen.main.bounds.width - 29)
        
        x = x + offset.x * ratio
        y = y + offset.y * ratio
        
        let cropRect = CGRect(x: x, y: y, width: cropSize, height: cropSize)
        let imageRef = self.cgImage?.cropping(to: cropRect)
        let cropped = UIImage(cgImage: imageRef!, scale: 0.0, orientation: self.imageOrientation)
        
        return cropped
    }
    
    func cropsToSquare2(rect: CGRect, size: CGSize) -> UIImage {
        
        let refWidth = CGFloat((self.cgImage!.width))
        let refHeight = CGFloat((self.cgImage!.height))
        
        let cropSize = refWidth > refHeight ? refHeight : refWidth
        let absSize = rect.width > rect.height ? rect.height : rect.width
        
        let scaleRatio = rect.width / size.width
        
        let ratio = cropSize / absSize
        
        var x = abs(rect.minX * ratio)
        var y = abs(rect.minY * ratio)
        
        let cropRect = CGRect(x: x, y: y, width: cropSize / scaleRatio, height: cropSize / scaleRatio)
        let imageRef = self.cgImage?.cropping(to: cropRect)
        let cropped = UIImage(cgImage: imageRef!, scale: 0.0, orientation: self.imageOrientation)
        
        return cropped
    }
    
    func resized(toWidth width: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
    
}
