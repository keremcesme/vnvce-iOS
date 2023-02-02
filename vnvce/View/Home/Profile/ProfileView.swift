
import SwiftUI
import PhotoSelectAndCrop
import YPImagePicker

struct ProfileView: View {
    @Environment(\.dismiss) public var dismiss
    
    @EnvironmentObject private var homeVM: HomeViewModel
    @EnvironmentObject private var currentUserVM: CurrentUserViewModel
    
    @StateObject private var pickerVM = ProfilePictureLibraryViewModel()
    
    @State private var showProfilePictureAction: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var showEditImage: Bool = false
    
    @State private var selectedImage: UIImage?
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top, content: BodyView)
                .clearBackground()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(Toolbar)
        }
        .cornerRadius(UIDevice.current.screenCornerRadius, corners: [.topLeft, .topRight])
        .ignoresSafeArea()
        .colorScheme(.dark)
    }
    
    @ViewBuilder
    private func BodyView() -> some View {
        Background
        VStack(spacing:0) {
            Divider()
            ScrollView {
                VStack(spacing: 15) {
                    ProfilePictureButton
                    if let selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .frame(width: 200, height: 200)
                    }
                }
                .padding(.top, 15)
            }
            Spacer()
        }
        .fullScreenCover(isPresented: $showImagePicker) {
            ProfilePictureImagePicker()
                .clearBackground()
        }
    }
    
    private func showImagePickerAction() {
        showImagePicker = true
    }
    
    @ViewBuilder
    private var ProfilePictureButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            self.showProfilePictureAction = true
        } label: {
            ZStack {
                Circle()
                    .foregroundColor(.secondary)
                    .frame(width: 120, height: 120)
                    .padding(5)
                    .background(Circle().fill(.white).opacity(0.2))
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(ScaledButtonStyle())
        .actionOver(isPresented: $showProfilePictureAction,
                    title: "Change your profile picture",
                    message: "Your profile picture is visible to everyone.",
                    buttons: [
                        .init(title: "Choose from library", type: .normal, action: showImagePickerAction),
                        .init(title: nil, type: .cancel, action: nil)
                    ])
        
    }
    
    @ViewBuilder
    private var Background: some View {
        BlurView(style: .systemMaterialDark)
            .overlay(.black.opacity(0.2))
            .ignoresSafeArea()
    }
    
}

extension ProfileView {
    @ToolbarContentBuilder
    public var Toolbar: some ToolbarContent {
        ToolbarItem(placement: .principal) { Title }
        ToolbarItem(placement: .navigationBarTrailing) { DismissButton }
    }
    
    @ViewBuilder
    private var Title: some View {
        Text(currentUserVM.user?.username.username ?? "")
            .font(.system(size: 16, weight: .semibold, design: .default))
            .frame(width: 150, alignment: .center)
    }
    
    @ViewBuilder
    private var DismissButton: some View {
        Button(action: dismiss) {
            Image(systemName: "xmark")
                .foregroundColor(.white)
                .font(.system(size: 18, weight: .semibold, design: .default))
                .contentShape(Rectangle())
        }
        .buttonStyle(ScaledButtonStyle())
    }
}

struct PickerTest: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> YPImagePicker {
        var config = YPImagePickerConfiguration()
        config.screens = [.library]
        
        config.targetImageSize = .cappedTo(size: 600)
        config.library.mediaType = .photo
        config.library.onlySquare = true
        
        let picker = YPImagePicker(configuration: config)
        
        picker.didFinishPicking(completion: { [unowned picker] items, isCancelled in
            defer { picker.dismiss(animated: true) }
            guard !isCancelled else { return }
            items.forEach({ item in
                switch item {
                case .photo(let photo):
                    // Image size not cropped to square.
                    // image size: (4032.0, 3024.0)
                    print("image size:", photo.image.size)
                default:
                    break
                }
            })
        })
        return picker
    }
    
    func updateUIViewController(_ uiView: YPImagePicker, context: Context) {
        
    }
}
