
import SwiftUI
import SwiftUIX

public struct MainView: View {
    @EnvironmentObject private var homeVM: HomeViewModel
    @EnvironmentObject private var cameraManager: CameraManager
    
    private func onChangeTab(_ id: String) {
        if id == homeVM.cameraRaw {
            cameraManager.startSession()
            homeVM.backgroundImage = nil
        } else {
            cameraManager.stopSession()
        }
    }
    
    public var body: some View {
        PageTabView(moments: Moments, users: Users)
        .onChange(of: homeVM.currentTab, perform: onChangeTab)
    }
    
    @ViewBuilder
    private func Moments() -> some View {
        ForEachData { index, $vm in
            LazyView {
                UserMomentsView(index, $vm)
            }
        }
    }
    
    @ViewBuilder
    private func Users() -> some View {
        ForEachData { index, $vm in
            UserCellView(index, $vm)
                .transition(.scale.combined(with: .opacity))
        }
    }
}

private extension MainView {
    private struct ForEachData<T: View>: View {
        @EnvironmentObject private var homeVM: HomeViewModel
        
        public typealias Content = (_ index: Int, _ vm: Binding<UserAndTheirMoments>) -> T
        
        private var content: Content
        
        public init(@ViewBuilder content: @escaping Content) {
            self.content = content
        }
        
        var body: some View {
            let data = Array($homeVM.usersAndTheirMoments.enumerated())
//            ForEach(data, id: \.element.user.detail.id, content: content)
            ForEach(data, id: \.element.user.detail.id) { index, $vm in
                self.content(index, $vm)
            }
        }
    }
}
