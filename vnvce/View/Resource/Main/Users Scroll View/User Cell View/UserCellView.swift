
import SwiftUI
import PureSwiftUI
import VNVCECore
import SDWebImageSwiftUI

extension HomeView {
    public struct UserCellView: View {
        @EnvironmentObject private var homeVM: HomeViewModel
        
        @Binding private var vm: UserAndTheirMoments
        @StateObject private var profilePictureManager = ImageManager()
        
        public var index: Int
        
        public init(_ index: Int, _ vm: Binding<UserAndTheirMoments>) {
            self.index = index
            self._vm = vm
        }
        
        private func tapAction() {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            homeVM.currentTab = vm.user.detail.id.uuidString
        }
        
        private var isSelected: Bool {
            return homeVM.currentTab == vm.user.detail.id.uuidString
        }
        
        public var body: some View {
            Button(action: tapAction) {
                VStack(spacing: 7) {
                    ProfilePictureView
                    .overlay(alignment: .topTrailing, content: MomentCountLabel)
                    BottomView
                }
                .animation(.easeInOut(duration: 0.3), value: homeVM.currentTab)
            }
            .buttonStyle(ScaledButtonStyle())
            .id(vm.user.detail.id.uuidString)
            .onAppear {
                profilePictureManager.cacheType = .disk
                if profilePictureManager.image == nil {
                    let url: URL? = URL(string: vm.user.detail.profilePictureURL! + ",sig=\(index)")
                    profilePictureManager.load(url: url)
                }
                
                print("[\(index)], on appeared.")
            }
        }
        
        @ViewBuilder
        private var ProfilePictureView: some View {
            ZStack {
                Group {
                    if let image = profilePictureManager.image {
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
                    } else {
                        Circle()
                            .fill(.primary.opacity(0.1))
                            .frame(homeVM.cell.size)
                            .shimmering()
                    }
                    
                }
                .clipShape(Circle())
            }
        }
        
        @ViewBuilder
        private func MomentCountLabel() -> some View {
            if vm.moments.count >= 2 && !isSelected {
                BlurView(style: .regular)
                    .frame(width: 25, height: 25)
                    .overlay {
                        Text("\(vm.moments.count)")
                            .foregroundColor(.primary)
                            .tracking(-0.25)
                            .font(.system(size: 12, weight: .medium, design: .default))
                    }
                    .clipShape(Circle())
                    .transition(.scale.combined(with: .opacity))
            }
        }
        
        @ViewBuilder
        private var BottomView: some View {
            if isSelected {
                Image(systemName: "chevron.down")
                    .foregroundColor(.secondary)
                    .font(.system(size: 16, weight: .semibold, design: .default))
                    .transition(.opacity.combined(with: .scale))
                
            } else {
                Text(vm.user.detail.displayName!)
                    .foregroundColor(.primary)
                    .tracking(-0.25)
                    .font(.system(size: 12, weight: .regular, design: .default))
                    .lineLimit(1)
                    .frame(maxWidth: homeVM.cell.size)
                    .transition(.opacity.combined(with: .scale))
            }
        }
    }
}

extension MainView {
    struct UserCellView: View {
        @EnvironmentObject public var homeVM: HomeViewModel
        
        @Binding private var vm: UserAndTheirMoments
        @StateObject public var profilePictureManager = ImageManager()
        
        public var index: Int
        
        init(_ index: Int, _ vm: Binding<UserAndTheirMoments>) {
            self.index = index
            self._vm = vm
        }
        
        public var isSelected: Bool {
            return homeVM.currentTab == vm.user.detail.id.uuidString
        }
        
        private func tapAction() {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            homeVM.currentTab = vm.user.detail.id.uuidString
        }
        
        private func downloadProfilePicture() {
            profilePictureManager.cacheType = .disk
            if profilePictureManager.image == nil {
                let url: URL? = URL(string: vm.user.detail.profilePictureURL! + ",sig=\(index)")
                profilePictureManager.load(url: url)
            }
        }
        
        public var body: some View {
            Button(action: tapAction, label: ButtonLabel)
                .buttonStyle(.scaled)
                .id(vm.user.detail.id.uuidString)
                .onAppear(perform: downloadProfilePicture)
                .animation(.easeInOut(duration: 0.3), value: homeVM.currentTab)
        }
        
        @ViewBuilder
        private func ButtonLabel() -> some View {
            VStack(spacing: 7, content: LabelVStackContent)
        }
        
        @ViewBuilder
        private func LabelVStackContent() -> some View {
            ProfilePicture
                .overlay(alignment: .topTrailing, content: MomentCount)
            BottomView
        }
        
        @ViewBuilder
        private func MomentCount() -> some View {
            if vm.moments.count >= 2 && !isSelected {
                BlurView(style: .regular)
                    .frame(width: 25, height: 25)
                    .overlay {
                        Text("\(vm.moments.count)")
                            .foregroundColor(.primary)
                            .tracking(-0.25)
                            .font(.system(size: 12, weight: .medium, design: .default))
                    }
                    .clipShape(Circle())
                    .transition(.scale.combined(with: .opacity))
            }
        }
        
        @ViewBuilder
        private var BottomView: some View {
            Group {
                if isSelected {
                    Image(systemName: "chevron.down")
                        .foregroundColor(.secondary)
                        .font(.system(size: 16, weight: .semibold, design: .default))
                } else {
                    Text(vm.user.detail.displayName!)
                        .foregroundColor(.primary)
                        .tracking(-0.25)
                        .font(.system(size: 12, weight: .medium, design: .default))
                        .lineLimit(1)
                        .frame(maxWidth: homeVM.cell.size)
                }
            }
            .transition(.opacity.combined(with: .scale))
        }
    }
}

