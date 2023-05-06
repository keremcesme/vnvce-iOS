
import SwiftUI
import PureSwiftUI
import VNVCECore
import Nuke
import NukeUI

extension HomeView {
    @ViewBuilder
    public func UserCell(_ inx: Int, user: VNVCECore.User.V1.Public, moments: [VNVCECore.Moment.V1.Public]) -> some View {
        Button {
            homeVM.currentTab = user.id.uuidString
            homeVM.bottomScrollTo(inx)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            VStack(spacing: 7) {
                ZStack {
                    LazyImage(url: URL(string: user.profilePictureURL!)) { state in
                        
                        Group {
                            if let uiImage = state.imageContainer?.image {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(isSelected(user) ? homeVM.cell.backgroundSelectedImageSize : homeVM.cell.backgroundImageSize)
                                BlurView(style: .dark)
                                    .frame(isSelected(user) ? homeVM.cell.selectedBlurSize : homeVM.cell.blurSize)
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(isSelected(user) ? homeVM.cell.selectedImageSize : homeVM.cell.imageSize)
                                Circle()
                                    .strokeBorder(.white, lineWidth: isSelected(user) ? 6 : 0)
                                    .foregroundColor(Color.clear)
                                    .frame(homeVM.cell.size)
                                    .opacity(isSelected(user) ? 1 : 0.0001)
                            } else {
                                Circle()
                                    .fill(.white.opacity(0.1))
                                    .frame(homeVM.cell.size)
                                    .shimmering()
                            }
                        }
                        .clipShape(Circle())
                    }.processors([ImageProcessors.Resize(width: 100)])
//                    Group {
//                        Image(user.profilePictureURL!)
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                            .frame(isSelected(user) ? homeVM.cell.backgroundSelectedImageSize : homeVM.cell.backgroundImageSize)
//                        BlurView(style: .dark)
//                            .frame(isSelected(user) ? homeVM.cell.selectedBlurSize : homeVM.cell.blurSize)
//                        Image(user.profilePictureURL!)
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                            .frame(isSelected(user) ? homeVM.cell.selectedImageSize : homeVM.cell.imageSize)
//                        Circle()
//                            .strokeBorder(.white, lineWidth: isSelected(user) ? 6 : 0)
//                            .foregroundColor(Color.clear)
//                            .frame(homeVM.cell.size)
//                            .opacity(isSelected(user) ? 1 : 0.0001)
//                    }
//                    .clipShape(Circle())
                }
                .overlay(alignment: .topTrailing) {
                    if moments.count >= 2 && homeVM.currentTab != user.id.uuidString {
                        BlurView(style: .dark)
                            .frame(width: 25, height: 25)
                            .overlay {
                                Text("\(moments.count)")
                                    .foregroundColor(.white)
                                    .tracking(-0.25)
                                    .font(.system(size: 12, weight: .medium, design: .default))
                            }
                            .clipShape(Circle())
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                 
                if homeVM.currentTab != user.id.uuidString {
                    Text(user.displayName!)
                        .foregroundColor(.white)
                        .tracking(-0.25)
                        .font(.system(size: 12, weight: .regular, design: .default))
                        .frame(maxWidth: homeVM.cell.size)
                        .transition(.opacity.combined(with: .scale))
                } else {
                    Image(systemName: "chevron.down")
                        .foregroundColor(.secondary)
                        .font(.system(size: 16, weight: .semibold, design: .default))
                        .transition(.opacity.combined(with: .scale))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: homeVM.currentTab)
        }
        .buttonStyle(ScaledButtonStyle())
        .id(user.id.uuidString)
    }
    
//    @ViewBuilder
//    public func UserCell(_ inx: Int, _ user: UserTestModel) -> some View {
//        Button {
//            homeVM.currentTab = user.id.uuidString
//            homeVM.bottomScrollTo(inx)
//            UIImpactFeedbackGenerator(style: .light).impactOccurred()
//        } label: {
//            VStack(spacing: 7) {
//                ZStack {
//                    Group {
//                        Image(user.picture)
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                            .frame(isSelected(user) ? 51 : 71)
//                        BlurView(style: .dark)
//                            .frame(isSelected(user) ? 51 : 72)
//                        Image(user.picture)
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                            .frame(isSelected(user) ? 51 : 64)
//                        Circle()
//                            .strokeBorder(.white, lineWidth: isSelected(user) ? 6 : 0)
//                            .foregroundColor(Color.clear)
//                            .frame(width: 72, height: 72, alignment: .center)
//                            .opacity(isSelected(user) ? 1 : 0.0001)
//                    }
//                    .clipShape(Circle())
//                }
//                .overlay(alignment: .topTrailing) {
//                    if user.count >= 2 && homeVM.currentTab != user.id.uuidString {
//                        BlurView(style: .dark)
//                            .frame(width: 25, height: 25)
//                            .overlay {
//                                Text("\(user.count)")
//                                    .foregroundColor(.white)
//                                    .tracking(-0.25)
//                                    .font(.system(size: 12, weight: .medium, design: .default))
//                            }
//                            .clipShape(Circle())
//                            .transition(.scale.combined(with: .opacity))
//                    }
//                }
//
//                if homeVM.currentTab != user.id.uuidString {
//                    Text(user.name)
//                        .foregroundColor(.white)
//                        .tracking(-0.25)
//                        .font(.system(size: 12, weight: .regular, design: .default))
//                        .frame(maxWidth: 79.5)
//                        .transition(.opacity)
//                }
//
//
//            }
//            .animation(.easeInOut(duration: 0.3), value: homeVM.currentTab)
//        }
//        .buttonStyle(ScaledButtonStyle())
//        .id(user.id.uuidString)
//    }
    
    private func isSelected(_ user: VNVCECore.User.V1.Public) -> Bool {
        return homeVM.currentTab == user.id.uuidString
    }
}
