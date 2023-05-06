
import SwiftUI
import SwiftUIX
import PureSwiftUI
import Nuke
import NukeUI

extension HomeView {
    @ViewBuilder
    public var CameraView: some View {
        GeometryReader(content: _CameraView)
            .tag(homeVM.cameraRaw)
    }
    
    private func getScale(_ proxy: GeometryProxy) -> CGFloat {
        let minX = abs(proxy.frame(in: .global).minX)
        return abs(1 - minX / homeVM.contentSize.width / 4)
    }
    
    private func getOpacity(_ proxy: GeometryProxy) -> CGFloat {
        let minX = abs(proxy.frame(in: .global).minX)
        return 1 - minX / homeVM.contentSize.width * 1.5
    }
    
    private func getBlurOpacity(_ proxy: GeometryProxy) -> CGFloat {
        let minX = abs(proxy.frame(in: .global).minX)
        return  minX / homeVM.contentSize.width * 2
    }
    
    private func getCornerRadius(_ proxy: GeometryProxy)  -> CGFloat {
        let minX = abs(proxy.frame(in: .global).minX)
        let radius = minX / 12.5
        return radius >= 25 ? 25 : radius
    }
    
    @ViewBuilder
    private func _CameraView(_ proxy: GeometryProxy) -> some View {
        if UIDevice.current.hasNotch() {
            VStack(spacing: 10){
                CameraNavigationBar
                    .opacity(getOpacity(proxy))
                    .scaleEffect(getScale(proxy), anchor: .leading)
                _CameraUIView(proxy)
                    .scaleEffect(getScale(proxy))
            }
        } else {
            ZStack(alignment: .topLeading){
                _CameraUIView(proxy)
                Group {
                    GradientForNoneNotch
                    CameraNavigationBar
                }
                    .opacity(getOpacity(proxy))
            }
            .cornerRadius(getCornerRadius(proxy), style: .continuous)
            .scaleEffect(getScale(proxy))
            .ignoresSafeArea()
        }
        
    }
    
    @ViewBuilder
    private var CameraNavigationBar: some View {
        GeometryReader {
            let height = $0.size.height
            HStack(spacing: 15){
                VNVCELogo.TextAndLogo()
                    .frame(height: height)
                Spacer()
                _AddFriendButton(height)
                _ProfileButton(height)
            }
        }
        .frame(height: homeVM.navBarHeight)
        .padding(.horizontal, 20)
        .padding(.top, !UIDevice.current.hasNotch() ? UIDevice.current.statusBarHeight() + 4 : 0)
        .opacity(!cameraManager.outputWillShowed ? 1 : 0.00001)
        .animation(.default, value: cameraManager.outputWillShowed)
    }
    
    @ViewBuilder
    private func _AddFriendButton(_ height: CGFloat) -> some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            self.homeVM.showSearchView = true
            self.cameraManager.stopSession()
        } label: {
            Circle()
                .fill(.ultraThinMaterial)
                .colorScheme(.dark)
                .frame(width: height, height: height)
                .overlay {
                    Image(systemName: "person.badge.plus")
                        .foregroundColor(.white).opacity(0.65)
                        .font(.system(size: 18, weight: .medium, design: .default))
                }
        }
        .buttonStyle(ScaledButtonStyle())
        .fullScreenCover(isPresented: $homeVM.showSearchView) {
            SearchView()
                .clearBackground()
                .environmentObject(searchVM)
                .environmentObject(contactsVM)
                
        }
    }
    
    @ViewBuilder
    private func _ProfileButton(_ height: CGFloat) -> some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            self.homeVM.showProfileView = true
            self.cameraManager.stopSession()
        } label: {
            if let url = currentUserVM.user?.profilePictureURL {
                LazyImage(url: URL(string: url)) { state in
                    if let uiImage = state.imageContainer?.image {
                        ZStack {
                            Group {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: height - 1, height: height - 1)
                                BlurView(style: .dark)
                                    .frame(width: height, height: height)
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: height - 5, height: height - 5)
                            }
                            .clipShape(Circle())
                        }
                    } else {
                        EmptyProfilePicture(height)
                    }
                }
                .pipeline(.shared)
                .processors([ImageProcessors.Resize(width: height)])
                .priority(.veryHigh)
            } else {
                EmptyProfilePicture(height)
            }
        }
        .buttonStyle(ScaledButtonStyle())
        .fullScreenCover(isPresented: $homeVM.showProfileView) {
            ProfileView()
                .clearBackground()
                .environmentObject(currentUserVM)
        }
    }
    
    @ViewBuilder
    private func EmptyProfilePicture(_ height: CGFloat) -> some View {
        Circle()
            .fill(.ultraThinMaterial)
            .colorScheme(.dark)
            .frame(width: height, height: height)
            .overlay {
                Image(systemName: "person.crop.circle")
                    .foregroundColor(.white).opacity(0.65)
                    .font(.system(size: height - 10, weight: .light, design: .default))
            }
    }
    
    @ViewBuilder
    private var GradientForNoneNotch: some View {
        LinearGradient(colors: [.black.opacity(0.5), .clear], startPoint: .top, endPoint: .bottom)
            .frame(height: UIDevice.current.statusBarHeight() + homeVM.navBarHeight + 10)
    }
    
    @ViewBuilder
    private func _CameraUIView(_ proxy: GeometryProxy) -> some View {
        Group {
            if UIDevice.current.hasNotch() {
                CameraViewUI()
                    .overlay(BlurLayer(proxy))
                    .cornerRadius(25, style: .continuous)
            } else {
                CameraViewUI()
                    .overlay(BlurLayer(proxy))
            }
        }
        .animation(.default, value: homeVM.currentTab)
        .animation(.default, value: cameraManager.sessionIsRunning)
        .yOffsetToYPositionIf(keyboardController.isShowed, keyboardOffset())
        .animation(.easeInOut(duration: keyboardController.duration), value: keyboardController.isShowed)
    }
    
    func keyboardOffset() -> CGFloat {
        let safeArea = UIScreen.main.bounds.height - keyboardController.height - homeVM.contentSize.height / 2 - 15
        return safeArea
    }
    
    @ViewBuilder
    private func BlurLayer(_ proxy: GeometryProxy) -> some View {
        if !cameraManager.sessionIsRunning && cameraManager.configurationStatus == .success {
            BlurView(style: .dark)
                .opacity(getBlurOpacity(proxy))
        }
        
    }
}
