
import SwiftUI
import SwiftUIX
import Nuke
import NukeUI
import VNVCECore

extension UserMomentsView.MomentView {
    public struct ImageView: View {
        @EnvironmentObject private var appState: AppState
        @EnvironmentObject public var currentUserVM: CurrentUserViewModel
        @EnvironmentObject public var homeVM: HomeViewModel

        @Binding public var vm: UserAndTheirMoments
        
        @Binding public var momentVM: MomentViewModel

        private var minX: CGFloat
        private var index: Int

        @State public var showBlur: Bool = true

        public init(minX: CGFloat, index: Int, vm: Binding<UserAndTheirMoments>, momentVM: Binding<MomentViewModel>) {
            self.minX = minX
            self.index = index
            self._vm = vm
            self._momentVM = momentVM
        }

        public var body: some View {
            Group {
                switch momentVM.imageDownloadState {
                case .nothing:
                    Color.red.opacity(0.1)
                case .downloading:
                    Color.white.opacity(0.1)
                case let .downloaded(image):
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
//                        .blur(showBlur ? 50 : 0)
//                        .scaleEffect(showBlur ? 1.3 : 1)
//                        .animation(.easeInOut(duration: 0.19), value: showBlur)
                        .onTapGesture {
                            vm.currentMomentIndex = 1
                        }
                }
            }
            .frame(homeVM.contentSize)
            .overlay{
                switch momentVM.imageDownloadState {
                case .nothing:
                    Text("Nothing")
                        .foregroundColor(.white)
                        .background(.black)
                case .downloading:
                    Text("Downlaoding")
                        .foregroundColor(.white)
                        .background(.black)
                case .downloaded(_):
                    Text("YES")
                        .foregroundColor(.white)
                        .background(.black)
                    
                }
                
            }
            .animation(.default, value: vm.moments[vm.currentMomentIndex].imageDownloadState)
            .clipped()
            .onChange(of: minX, perform: blurTask)
            .onChange(of: appState.scenePhase) {
                switch $0 {
                case .background, .inactive:
                    showBlur = true
                case .active:
                    blurTask(minX)
                @unknown default:
                    showBlur = true
                }
            }
            .onChange(of: homeVM.currentTab) {
                if case let .downloaded(image) = vm.moments[vm.currentMomentIndex].imageDownloadState, $0 == vm.user.detail.id.uuidString && homeVM.backgroundImage != image {
                    homeVM.backgroundImage = image
                }
            }
            .onChange(of: vm.moments[vm.currentMomentIndex].imageDownloadState) {
                if case let .downloaded(image) = $0, homeVM.currentTab == vm.user.detail.id.uuidString, homeVM.backgroundImage != image {
                    homeVM.backgroundImage = image
                }
            }
        }

        func blurTask(_ minX: CGFloat) {
            if minX == 0 && vm.user.detail.id.uuidString == homeVM.currentTab {
                showBlur = false
            } else {
                showBlur = true
            }
        }

    }
}
