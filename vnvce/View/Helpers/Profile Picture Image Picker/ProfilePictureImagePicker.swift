
import SwiftUI
import PhotosUI

struct ProfilePictureImagePicker: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedImage = UIImage()
    @State private var showCropView: Bool = false
    
    var body: some View {
        NavigationView {
            Group {
                if #available(iOS 16.0, *) {
                    PHPicker(image: $selectedImage, showCropView: $showCropView)
                        .toolbar(.hidden, for: .navigationBar)
                } else {
                    PHPickeriOS15(image: $selectedImage, showCropView: $showCropView)
                        .navigationBarHidden(true)
                }
            }
            .ignoresSafeArea()
            .background {
                NavigationLink("", isActive: $showCropView) {
                    ProfilePictureCropView(image: selectedImage)
                }
            }
        }
        .cornerRadius(UIDevice.current.screenCornerRadius, corners: [.topLeft, .topRight])
        .ignoresSafeArea()
        .colorScheme(.dark)
    }
    
    private struct PHPicker: UIViewControllerRepresentable {
        @Binding var image: UIImage
        @Binding var showCropView: Bool
        
        func makeUIViewController(context: Context) -> PHPickerViewController {
            var config = PHPickerConfiguration()
            config.filter = .images
            config.selectionLimit = 1
            let picker = PHPickerViewController(configuration: config)
            picker.delegate = context.coordinator
            return picker
        }
        
        func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
            
        }
        
        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }
        
        class Coordinator: NSObject, PHPickerViewControllerDelegate {
            let parent: PHPicker
            
            init(_ parent: PHPicker) {
                self.parent = parent
            }
            
            
            func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
                guard let provider = results.first?.itemProvider,
                          provider.canLoadObject(ofClass: UIImage.self) else {
                          picker.dismiss(animated: true)
                    return
                }
                provider.loadObject(ofClass: UIImage.self) { image, error in
                    guard error == nil,
                    let image = image as? UIImage
                    else {
                        picker.dismiss(animated: true)
                        return
                    }
                    self.parent.image = image
                    self.parent.showCropView = true
                }
            }
        }
    }
    
    private struct PHPickeriOS15: UIViewControllerRepresentable {
        @Binding var image: UIImage
        @Binding var showCropView: Bool
        
        func makeUIViewController(context: Context) -> UIImagePickerController {
            let imagePicker = UIImagePickerController()
            imagePicker.mediaTypes = ["public.image"]
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.delegate = context.coordinator
            
            return imagePicker
        }
        
        func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
            
        }
        
        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }
        
        class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
            let parent: PHPickeriOS15
            
            init(_ parent: PHPickeriOS15) {
                self.parent = parent
            }
            
            func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
                
                guard let image = info[.originalImage] as? UIImage else {
                    picker.dismiss(animated: true)
                    return
                }
                
                parent.image = image
                parent.showCropView = true
                
            }
            
        }
    }
    
}
