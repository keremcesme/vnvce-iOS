
import SwiftUI
import PureSwiftUI


struct ProfilePictureCropView: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject private var currentUserVM: CurrentUserViewModel
    
    @StateObject private var gestureController = ProfilePictureCropGestureController()
    
    private let screen = UIScreen.main.bounds
    
    @State private var isInteracting: Bool = false
    @State private var isUploading: Bool = false
    
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    
    @State private var renderSize: CGSize = .zero
    @State private var renderRect: CGRect = .zero
    
    let image: UIImage
    let dismissPicker: () -> ()
    
    init(image: UIImage, dismiss: @escaping () -> ()) {
        self.image = image
        self.dismissPicker = dismiss
    }
    
    private func cropToSquare(_ rect: CGRect, _ size: CGSize) -> UIImage {
        
        let refWidth = CGFloat((self.image.cgImage!.width))
        let refHeight = CGFloat((self.image.cgImage!.height))
        
        let cropSize = refWidth > refHeight ? refHeight : refWidth
        let absSize = rect.width > rect.height ? rect.height : rect.width
        
        let ratio = cropSize / absSize
        
        let x = abs(rect.minX * ratio)
        let y = abs(rect.minY * ratio)
        
        let scaleRatio = rect.width / size.width
        let crop = cropSize / scaleRatio
        
        let cropRect = CGRect(x: x, y: y, width: crop, height: crop)
        let imageRef = self.image.cgImage?.cropping(to: cropRect)
        let cropped = UIImage(cgImage: imageRef!, scale: 0.0, orientation: self.image.imageOrientation)
        
        return cropped
    }
    
    @MainActor
    private func upload(_ rect: CGRect, _ size: CGSize) async {
        guard let image = cropToSquare(rect, size).resized(toWidth: 300) else {
            return
        }
        
        do {
//            if let name = currentUserVM.user?.profilePicture?.name {
//                try await StorageAPI().deleteProfilePicture(name)
//            }
            
            let url = try await StorageAPI().uploadProfilePicture(image)
            try await MeAPI().editProfilePicture(.init(url: url))
            self.currentUserVM.user!.profilePictureURL = url
            
            self.isUploading = false
            
            dismissPicker()
        } catch {
            print(error.localizedDescription)
            self.isUploading = false
            return
        }
    }
    
    var body: some View {
        ZStack {
            Background
            CropArea.overlay(MaskView)
            GestureView(isInteracting: $isInteracting, offset: $offset, lastOffset: $lastOffset, scale: $scale, lastScale: $lastScale)
            SaveButton
            UploadingView
        }
        .clipped()
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
    
    @ViewBuilder
    private func GestureOnEndOverlay(_ size: CGSize) -> some View {
        GeometryReader {
            let rect = $0.frame(in: .named("CROP_VIEW"))
            let absSize = $0.size
            Color.clear
                .onChange(of: isUploading) {
                    if $0 {
                        Task {
                            await upload(rect, absSize)
                        }
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                            let image = cropToSquare(rect: rect, size: absSize).resized(toWidth: 300)
//
//                            ImageSaver().writeToPhotoAlbum(image: image!)
//                            self.isUploading = false
//                        }
                    }
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
                        }
                    }
                    
                }
        }
    }
    
    @ViewBuilder
    private var SaveButton: some View {
        VStack {
            Spacer()
            Button {
                self.isUploading = true
            } label: {
                Text("Save")
                    .foregroundStyle(.linearGradient(
                        colors: [Color.init(hex: "53E6CA"), Color.init(hex: "6A3FFB")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing))
                    .font(.system(size: 14, weight: .semibold, design: .default))
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(.white))
                    .contentShape(Rectangle())
                    .padding(.bottom, UIDevice.current.bottomSafeAreaHeight() + 15)
            }
            .buttonStyle(ScaledButtonStyle())
            .disabled(isUploading)
        }
    }
    
    @ViewBuilder
    private var UploadingView: some View {
        if isUploading {
            Color.black.opacity(0.6)
                .overlay {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.secondary)
                }
                .colorScheme(.dark)
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
    
    private func haptic() {
        if !isInteracting {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
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
        .disabled(isUploading)
    }
}

//extension UIImage {
//    func cropsToSquare(offset: CGSize, scale: CGFloat) -> UIImage {
//        let refWidth = CGFloat((self.cgImage!.width))
//        let refHeight = CGFloat((self.cgImage!.height))
//        let cropSize = refWidth > refHeight ? refHeight : refWidth
//
//        var x = (refWidth - cropSize) / 2.0
//        var y = (refHeight - cropSize) / 2.0
//
//        let ratio = -cropSize / (UIScreen.main.bounds.width - 29)
//
//        x = x + offset.x * ratio
//        y = y + offset.y * ratio
//
//        let cropRect = CGRect(x: x, y: y, width: cropSize, height: cropSize)
//        let imageRef = self.cgImage?.cropping(to: cropRect)
//        let cropped = UIImage(cgImage: imageRef!, scale: 0.0, orientation: self.imageOrientation)
//
//        return cropped
//    }
//
//    func cropsToSquare2(rect: CGRect, size: CGSize) -> UIImage {
//
//        let refWidth = CGFloat((self.cgImage!.width))
//        let refHeight = CGFloat((self.cgImage!.height))
//
//        let cropSize = refWidth > refHeight ? refHeight : refWidth
//        let absSize = rect.width > rect.height ? rect.height : rect.width
//
//        let scaleRatio = rect.width / size.width
//
//        let ratio = cropSize / absSize
//
//        var x = abs(rect.minX * ratio)
//        var y = abs(rect.minY * ratio)
//
//        let cropRect = CGRect(x: x, y: y, width: cropSize / scaleRatio, height: cropSize / scaleRatio)
//        let imageRef = self.cgImage?.cropping(to: cropRect)
//        let cropped = UIImage(cgImage: imageRef!, scale: 0.0, orientation: self.imageOrientation)
//
//        return cropped
//    }
//
//
//
//}
