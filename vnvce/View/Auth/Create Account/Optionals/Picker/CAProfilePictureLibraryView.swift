//
//  CAProfilePictureLibraryView.swift
//  vnvce
//
//  Created by Kerem Cesme on 23.08.2022.
//

import SwiftUI
import Photos
//import PureSwiftUI
//import SwiftUIX

struct CAProfilePictureLibraryView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var picker: ProfilePictureLibraryViewModel
    @State private var scrollToTop: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top){
                Color.black
                    .ignoresSafeArea()
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing:0) {
                            Color.primary.opacity(0.000001)
                                .frame(.zero)
                                .id("TOP")
                            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                                Section {
                                    GridLayoutView
                                } header: {
                                    HeaderView
                                }
                            }
                        }
                        
                    }
                    .onChange(of: scrollToTop) { _ in
                        withAnimation(.spring(response: 0.2, dampingFraction: 1, blendDuration: 0)) {
                            proxy.scrollTo("TOP", anchor: .top)
                        }
                    }
                }
               
            }
            .navigationTitle("Photo Library")
            .navigationBarBackButtonHidden(true)
            .toolbar(ToolBar)
        }
        .accentColor(.primary)
    }
}

extension CAProfilePictureLibraryView {
    @ViewBuilder
    private var GridLayoutView: some View {
        switch picker.currentAlbum {
            case .all:
                GridLayout(items: picker.assets,
                     id: \.id,
                     spacing: 1,
                     columnCount: 4,
                     cellRatio: 1) { item in
                    Cell(item: item, dismiss: dismiss)
                }
            case .favorites:
                GridLayout(items: picker.favoriteAssets,
                     id: \.id,
                     spacing: 1,
                     columnCount: 4,
                     cellRatio: 1) { item in
                    Cell(item: item, dismiss: dismiss)
                }
        }
    }
    
    @ViewBuilder
    private var HeaderView: some View {
        HStack(spacing: 18){
            headerButton(type: .all, action: picker.fetchAllAssets)
            headerButton(type: .favorites, action: picker.fetchFavoriteAssets)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 18)
    }
    
    @ViewBuilder
    private func headerButton(type: ProfilePictureLibraryViewModel.AlbumType, action: @escaping @Sendable @MainActor () async -> ()) -> some View {
        Button {
            self.scrollToTop.toggle()
            Task(operation: action)
        } label: {
            ZStack {
                Group {
                    if picker.currentAlbum == type {
                        Color.primary
                    } else {
                        BlurView(style: .systemThinMaterial)
                    }
                }
                .cornerRadius(10)
                if picker.currentAlbum == type {
                    Text(type.rawValue)
                        .font(.system(size: 14, weight: .semibold, design: .default))
                        .foregroundColor(.primary)
                        .colorInvert()
                } else {
                    Text(type.rawValue)
                        .font(.system(size: 14, weight: .semibold, design: .default))
                        .foregroundColor(.primary)
                }
                
            }
            .frame(maxWidth: .infinity)
            .frame(height: 35)
        }

    }
    
}

extension CAProfilePictureLibraryView {
    private struct Cell: View {
        
        @EnvironmentObject private var picker: ProfilePictureLibraryViewModel
        @EnvironmentObject private var vm: CreateAccountViewModel
        
        @State var image: UIImage = UIImage()
        
        let item: LibraryAsset
        let dismiss: () -> ()
        
        private func tapAction() {
            DispatchQueue.global().async {
                let manager = PHImageManager.default()
                let option = PHImageRequestOptions()
                option.deliveryMode = .highQualityFormat
                option.isSynchronous = true
                option.isNetworkAccessAllowed = true
                option.version = .current
                
                let maxWidth: CGFloat = 360
                let maxHeight: CGFloat = 480
                let size = CGSize(width: maxWidth, height: maxHeight)
                manager.requestImage(
                    for: item.asset,
                    targetSize: size,
                    contentMode: .aspectFit,
                    options: option
                ) { image, _ in
                    if let image = image {
                        DispatchQueue.main.async {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            self.vm.profilePicture = image
                            self.dismiss()
                        }
                    }
                }
            }
        }
        
        private func fetchAsset() {
//            fetchAssetTask()
        }
       
        private func fetchAssetTask() {
            DispatchQueue.global(qos: .userInitiated).async {
                let manager = PHImageManager.default()
                let option = PHImageRequestOptions()
                var thumbnail = UIImage()
                let targetWidth = UIScreen.main.bounds.width / 3
                option.deliveryMode = .opportunistic
                option.resizeMode = .none
                option.isSynchronous = true
                option.isNetworkAccessAllowed = true
                option.version = .current
                
                manager.requestImage(for: item.asset, targetSize: CGSize(width: targetWidth, height: targetWidth * 1.7), contentMode: .aspectFit, options: option, resultHandler: {(result, info) -> Void in
                    if let result = result  {
                        thumbnail = result
                    }
                })
                DispatchQueue.main.async {
                    self.image = thumbnail
                }
            }
        }
        
        var body: some View {
            GeometryReader {
//                let frame = $0.frame(in: .global)
                let size = $0.size
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(size)
                    .clipped()
                    .overlay(Favorite, alignment: .topTrailing)
                    .background(Color.white.opacity(0.075))
                    .contentShape(Rectangle())
                    .onPress(perform: tapAction)
            }
            .taskInit(fetchAsset)
        }
        
        @ViewBuilder
        private var Favorite: some View {
            if item.asset.isFavorite {
                Image(systemName: "heart.fill")
                    .foregroundColor(.pink)
                    .font(.system(size: 14, weight: .medium, design: .default))
                    .padding(5)
                    .shadow(3)
            }
        }
    }
}

// Navigation Bar
extension CAProfilePictureLibraryView {
    @ToolbarContentBuilder
    var ToolBar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) { BackButton }
    }
    
    @ViewBuilder
    var BackButton: some View {
        Button(action: dismiss) {
            Text("Cancel")
                .foregroundColor(.primary)
                .font(.system(size: 16, weight: .medium, design: .default))
        }
    }
}
