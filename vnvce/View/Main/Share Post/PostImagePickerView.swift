//
//  PostImagePickerView.swift
//  vnvce
//
//  Created by Kerem Cesme on 11.09.2022.
//

import SwiftUI
import AVFoundation

struct PostImagePickerView: View {
    @EnvironmentObject var uploadPostVM: UploadPostViewModel
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            NavigationView {
                ZStack {
                    CurrentUserBackground()
                    NavigationLink(isActive: $uploadPostVM.showOutputView) {
                        Button {
                            self.uploadPostVM.showUploadPostView = false
                            Task {
                                await uploadPostVM.uploadPost()
                                await MainActor.run {
                                    self.uploadPostVM.showOutputView = false
                                }
                            }
                        } label: {
                            Text("Upload").font(.title.bold())
                                .foregroundColor(.red)
                        }
                    } label: {
                        EmptyView()
                    }

                    PostImagePickerUIView()
                        .ignoresSafeArea()
                }
                .navigationBarHidden(true)
                .navigationBarBackButtonHidden(true)
                .ignoresSafeArea()
            }
            .ignoresSafeArea()
        }
    }
}

struct PostImagePickerUIView: UIViewControllerRepresentable {
    @EnvironmentObject var uploadPostVM: UploadPostViewModel
    
    func makeUIViewController(context: Context) -> YPImagePicker {
        var config = YPImagePickerConfiguration()
        config.screens = [.library]
        config.library.maxNumberOfItems = 1
        config.library.mediaType = .photo
        config.hidesCancelButton = false
        config.hidesStatusBar = false
        config.library.numberOfItemsInRow = 4
        config.showsPhotoFilters = false
        config.showsCropGridOverlay = true
        config.showsVideoTrimmer = true
        
        config.video.compression = AVAssetExportPresetHEVC1920x1080
        config.targetImageSize = .cappedTo(size: 1440)
        config.hidesBottomBar = true
        config.library.defaultMultipleSelection = false
        config.library.maxNumberOfItems = 1
        config.library.minNumberOfItems = 1
        config.video.libraryTimeLimit = 600.0
        config.video.minimumTimeLimit = 1.0
        config.video.trimmerMaxDuration = 120.0
        config.video.trimmerMinDuration = 1.0
        config.video.fileType = .mp4
        config.shouldSaveNewPicturesToAlbum = false
        config.onlySquareImagesFromCamera = true
        config.library.onlySquare = false
        
        
        config.isScrollToChangeModesEnabled = false
        config.startOnScreen = .library
        
        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking { [unowned picker] items, img in
            print(picker)
            if let photo = items.singlePhoto {
//                newPostViewModel.media = .image(image: photo.image)
//                newPostViewModel.selectedMediaType = .image
//                newPostViewModel.selectedImage = photo.image
//                newPostViewModel.showOutput = true
//                newPostViewModel.metadata = photo.exifMeta
                uploadPostVM.selectedImage = photo.image
                uploadPostVM.showOutputView = true
                if photo.image.size.width > photo.image.size.height {
                    // Landscape
                    print(photo.image.size.width / photo.image.size.height)
                    
                }
                
                if photo.image.size.width < photo.image.size.height {
                    // Portrait
                    
                }
            } else {
                uploadPostVM.showUploadPostView = false
//                uploadPostVM.showView = false
//                newPostModalController.openNewPost = false
                
            }
        }
        
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: YPImagePicker, context: Context) {
        
    }
}


