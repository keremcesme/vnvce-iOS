
import SwiftUI
import SwiftUIX
import PureSwiftUI

struct UsersScrollView<Users: View>: View {
    @EnvironmentObject public var homeVM: HomeViewModel
    @EnvironmentObject private var cameraManager: CameraManager
    
    private var discoveryButtonAction: () -> Void
    private var users: Users
    
    public init(
        _ discoveryAction: @escaping () -> Void,
        @ViewBuilder users: @escaping () -> Users
    ) {
        self.discoveryButtonAction = discoveryAction
        self.users = users()
    }
    
    private func topPadding() -> CGFloat {
        if UIDevice.current.hasNotch() {
            return homeVM.contentSize.height + homeVM.navBarHeight + UIDevice.current.statusBarHeight() + 10 + 15
        } else {
            return homeVM.contentSize.height + 10
        }
    }
    
    var body: some View {
        ScrollViewReader(content: ScrollViewReaderContent)
            .opacity(!cameraManager.outputWillShowed ? 1 : 0.00001)
            .animation(.default, value: cameraManager.outputWillShowed)
    }
    
    @ViewBuilder
    private func ScrollViewReaderContent(_ proxy: ScrollViewProxy) -> some View {
        ScrollView(.horizontal, showsIndicators: false, content: ScrollViewContent)
            .padding(.top, topPadding())
            .onChange(of: homeVM.currentTab) { id in
                withAnimation {
                    proxy.scrollTo(id, anchor: .center)
                }
            }
            .onChange(of: cameraManager.outputDidShowed) {
                if !$0 {
                    proxy.scrollTo(homeVM.cameraRaw, anchor: .center)
                }
            }
    }
    
    @ViewBuilder
    private func ScrollViewContent() -> some View {
        LazyHStack(alignment: .top, spacing: 15, content: LazyHStackContent)
            .padding(.horizontal, UIScreen.main.bounds.width / 2 - 36)
    }
    
    @ViewBuilder
    private func LazyHStackContent() -> some View {
        DiscoveryButton(action: discoveryButtonAction)
        HDivider
        Group {
            if !homeVM.momentsIsLoading {
                // MARK: USERS
                self.users
            } else {
                RedactedUsers()
            }
        }
        .animation(.default, value: homeVM.momentsIsLoading)
        
    }
    
    @ViewBuilder
    private var HDivider: some View {
        Capsule()
            .fill(.primary.opacity(0.15))
            .frame(1, 30)
            .yOffset(homeVM.cell.size / 2 - 15)
    }
    
}
