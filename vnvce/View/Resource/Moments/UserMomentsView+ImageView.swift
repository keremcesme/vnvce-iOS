
import SwiftUI
import SwiftUIX
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
        
        public init(minX: CGFloat , userWithMoments: Binding<UserWithMoments.V1>, momentsVM: UserMomentsViewModel) {
            self.minX = minX
            self._userWithMoments = userWithMoments
            self._momentsVM = StateObject(wrappedValue: momentsVM)
        }
        
        public var body: some View {
            Image(momentsVM.currentMoment.media.url)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .blur(showBlur ? 50 : 0)
                .animation(.easeInOut(duration: 0.19), value: showBlur)
                .frame(momentsStore.momentSize)
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
            if minX == 0 && userWithMoments.owner.id.uuidString == homeVM.tab {
                showBlur = false
            } else {
                showBlur = true
            }
        }
        
    }
}
