
import SwiftUI
import SwiftUIX
import Nuke
import NukeUI
import VNVCECore

extension UserMomentsView {
    public struct ImageView: View {
        @EnvironmentObject private var appState: AppState
        @EnvironmentObject public var currentUserVM: CurrentUserViewModel
        @EnvironmentObject public var homeVM: HomeViewModel
        @EnvironmentObject public var momentsStore: UserMomentsStore
        
        @StateObject public var momentsVM: UserMomentsViewModel
        
        private var minX: CGFloat
        
        @Binding public var userWithMoments: UserWithMoments.V1
        
        @State public var showBlur: Bool = true
        
        public init(minX: CGFloat, userWithMoments: Binding<UserWithMoments.V1>, momentsVM: UserMomentsViewModel) {
            self.minX = minX
            self._userWithMoments = userWithMoments
            self._momentsVM = StateObject(wrappedValue: momentsVM)
        }
        
        public var body: some View {
            LazyImage(url: URL(string: momentsVM.currentMoment.url)) { state in
                Group {
                    if let uiImage = state.imageContainer?.image {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .blur(showBlur ? 50 : 0)
                            .scaleEffect(showBlur ? 1.1 : 1)
                            .animation(.easeInOut(duration: 0.19), value: showBlur)
                    } else {
                        Color.white.opacity(0.1)
                    }
                }
                .frame(momentsStore.momentSize)
                .clipped()
            }
            .processors([ImageProcessors.Resize(width: 1440)])
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
        }
        
        func blurTask(_ minX: CGFloat) {
            if minX == 0 && userWithMoments.owner.id.uuidString == homeVM.currentTab {
                showBlur = false
            } else {
                showBlur = true
            }
        }
        
    }
}
