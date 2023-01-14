
import SwiftUI
import PhotosUI
import PureSwiftUI

extension View {
    @ViewBuilder
    public func cropImagePicker(show: Binding<Bool>, croppedImage: Binding<UIImage?>) -> some View {
        if #available(iOS 16.0, *) {
            CustomImagePickeriOS16(show: show, croppedImage: croppedImage) {
                self
            }
        } else {
            CustomImagePickeriOS15(show: show, croppedImage: croppedImage) {
                self
            }
        }
        
    }
}

@available(iOS 16.0, *)
fileprivate struct CustomImagePickeriOS16<Content: View>: View {
    var content: Content
    
    @Binding private var show: Bool
    @Binding private var croppedImage: UIImage?
    
    init(
        show: Binding<Bool>,
        croppedImage: Binding<UIImage?>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._show = show
        self._croppedImage = croppedImage
        self.content = content()
    }
    
    @State private var photosItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var showCropView: Bool = false
    
    var body: some View {
        content
            .photosPicker(isPresented: $show, selection: $photosItem)
            .onChange(of: photosItem) {
                if let newValue = $0 {
                    Task {
                        if let imageData = try? await newValue.loadTransferable(type: Data.self),
                           let image = UIImage(data: imageData) {
                            await MainActor.run {
                                selectedImage = image
                                showCropView = true
                            }
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $showCropView) {
                selectedImage = nil
            } content: {
                CropView(image: selectedImage) { croppedImage, status in
                    if let croppedImage {
                        self.croppedImage = croppedImage
                    }
                }
            }

    }
}

fileprivate struct CustomImagePickeriOS15<Content: View>: View {
    var content: Content
    
    @Binding private var show: Bool
    @Binding private var croppedImage: UIImage?
    
    init(
        show: Binding<Bool>,
        croppedImage: Binding<UIImage?>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._show = show
        self._croppedImage = croppedImage
        self.content = content()
    }
    
    
    var body: some View {
        content
    }
}

struct CropView: View {
    @Environment(\.dismiss) public var dismiss
    
    var image: UIImage?
    var onCrop: (UIImage?, Bool) -> ()

    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 0
    @State private var offset: CGSize = .zero
    @State private var lastStoredOffset: CGSize = .zero
    @GestureState private var isInteracting: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Button(action: dismiss) {
                    Text("Dismiss")
                }
                
                Button {
                    if #available(iOS 16.0, *) {
                        let renderer = ImageRenderer(content: ImageView(true))
                        renderer.proposedSize = .init(.init(300, 300))
                        if let image = renderer.uiImage {
                            onCrop(image, true)
                        } else {
                            onCrop(nil, false)
                        }
                    } else {
                        let image = ImageView(true).snapshot()
                        onCrop(image, true)
                    }
                } label: {
                    Text("Save")
                }

            }
            ImageView()
        }
        
    }
    
    @ViewBuilder
    private func ImageView(_ hideGrids: Bool = false) -> some View {
        GeometryReader {
            let size = $0.size
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .overlay{
                        GeometryReader{
                            let rect = $0.frame(in: .named("CROP_VIEW"))
                            Color.clear
                                .onChange(of: isInteracting) {
                                    
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
                                    
                                    if !$0 {
                                        lastStoredOffset = offset
                                    }
                                }
                        }
                    }
                    .frame(size)
            }
        }
        .scaleEffect(scale)
        .offset(offset)
        .overlay {
            if !hideGrids {
                Grids
            }
        }
        .coordinateSpace(name: "CROP_VIEW")
        .gesture(
            DragGesture()
                .updating($isInteracting) { _, out, _ in
                    out = true
                }
                .onChanged{ value in
                    let translation = value.translation
                    offset = CGSize(translation.width + lastStoredOffset.width, translation.height + lastStoredOffset.height)
                }
        )
        .gesture(
            MagnificationGesture()
                .updating($isInteracting) { _, out, _ in
                    out = true
                }
                .onChanged{ value in
                    let updatedScale = value + lastScale
                    scale = (updatedScale < 1 ? 1 : updatedScale)
                }
                .onEnded{ _ in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if scale < 1 {
                            scale = 1
                            lastScale = 0
                        } else {
                            lastScale = scale - 1
                        }
                    }
                }
        )
        .frame(width: 300, height: 300)
        .clipShape(Circle())
    }
    
    @ViewBuilder
    private var Grids: some View {
        ZStack {
            HStack {
                ForEach(1...5, id: \.self) {_ in
                    Rectangle()
                        .fill(.white.opacity(0.7))
                        .frame(width: 1)
                        .frame(maxWidth: .infinity)
                }
            }
            VStack {
                ForEach(1...5, id: \.self) {_ in
                    Rectangle()
                        .fill(.white.opacity(0.7))
                        .frame(height: 1)
                        .frame(maxHeight: .infinity)
                }
            }
        }
    }
    
    private func haptic() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}

extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view

        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)

        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}
