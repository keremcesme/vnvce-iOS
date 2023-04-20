
import SwiftUI
import SwiftUIX
import VNVCECore

struct UserMomentsView: View {
    
    @EnvironmentObject public var currentUserVM: CurrentUserViewModel
    @EnvironmentObject public var homeVM: HomeViewModel
    @EnvironmentObject public var momentsStore: UserMomentsStore
    
    @StateObject public var momentsVM: UserMomentsViewModel
    
    public var index: Int
    
    @Binding public var userWithMoments: UserWithMoments.V1
    
    public init(_ index: Int, _ userWithMoments: Binding<UserWithMoments.V1>) {
        self.index = index
        self._userWithMoments = userWithMoments
        self._momentsVM = StateObject(wrappedValue: UserMomentsViewModel(first: userWithMoments.moments[0].wrappedValue))
    }
    
    var body: some View {
        GeometryReader(content: ContentView)
            .tag(userWithMoments.owner.id.uuidString)
            .onChange(of: homeVM.tab) {
                if $0 == userWithMoments.owner.id.uuidString {
                    momentsStore.currentMoment = momentsVM.currentMoment
                }
            }
            .onChange(of: momentsVM.currentMomentIndex) {
                let currentMoment = userWithMoments.moments[$0]
                momentsVM.currentMoment = currentMoment
                momentsStore.currentMoment = currentMoment
            }
            .onTapGesture {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                momentsVM.currentMomentIndex = 1
            }
    }
    
    @ViewBuilder
    private func ContentView(_ proxy: GeometryProxy) -> some View {
        switch UIDevice.current.hasNotch() {
        case true: NotchView(proxy)
        case false: NonNotchView(proxy)
        }
    }
    
    @ViewBuilder
    private func NotchView(_ proxy: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            NavigationBar
                .opacity(getOpacity(proxy))
                .scaleEffect(getScale(proxy), anchor: .leading)
            MomentView(proxy)
                .cornerRadius(25, style: .continuous)
                .scaleEffect(getScale(proxy))
        }
    }
    
    @ViewBuilder
    private func NonNotchView(_ proxy: GeometryProxy) -> some View {
        ZStack(alignment: .topLeading){
            MomentView(proxy)
            Group {
                LinearGradient(colors: [.black.opacity(0.5), .clear], startPoint: .top, endPoint: .bottom)
                    .frame(height: UIDevice.current.statusBarHeight() + momentsStore.navBarHeight + 10)
                NavigationBar
            }
            .opacity(getOpacity(proxy))
        }
        .cornerRadius(getCornerRadius(proxy), style: .continuous)
        .scaleEffect(getScale(proxy))
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    private func MomentView(_ proxy: GeometryProxy) -> some View {
        ImageView(minX: abs(proxy.frame(in: .global).minX),
                  userWithMoments: $userWithMoments,
                  momentsVM: momentsVM)
//        Image(momentsVM.currentMoment.media.url)
//            .resizable()
//            .aspectRatio(contentMode: .fill)
//            .blur(getBlur(proxy))
//            .blur(homeVM.showBlur ? 50 : 0)
//            .animation(.default, value: homeVM.showBlur)
//            .frame(momentsStore.momentSize)
//            .onChange(of: homeVM.touchesBegan) { value in
//                if value || userWithMoments.owner.id.uuidString != homeVM.tab {
//                    homeVM.showBlur = true
//                } else {
//                    let minX = abs(proxy.frame(in: .global).minX)
//
//                    if minX != 0 {
//                        homeVM.showBlur = true
//                    } else {
//                        homeVM.showBlur = false
//                    }
//                }
//            }
//            .overlay {
//                BlurView(style: .dark)
//                    .opacity(getBlurOpacity2(proxy))
//            }
    }
}

extension UserMomentsView {
    
    public func getScale(_ proxy: GeometryProxy) -> CGFloat {
        let minX = abs(proxy.frame(in: .global).minX)
        return abs(1 - minX / momentsStore.momentSize.width / 4)
    }
    
    public func getOpacity(_ proxy: GeometryProxy) -> CGFloat {
        let minX = abs(proxy.frame(in: .global).minX)
        return 1 - minX / momentsStore.momentSize.width * 1.5
    }
    
    private func blur(_ proxy: GeometryProxy) -> Bool {
        return true
    }
    
    private func getBlur(_ proxy: GeometryProxy) -> CGFloat {
        if homeVM.touchesBegan {
            return 50
        } else {
            let minX = abs(proxy.frame(in: .global).minX)
            
            return minX != 0 ? 50 : 0
        }
        
//        let value = minX / momentsStore.momentSize.width * 200
//
//        return value <= 50 ? value : 50
    }
    
    private func getBlurOpacity2(_ proxy: GeometryProxy) -> CGFloat {
        let minX = abs(proxy.frame(in: .global).minX)
        return minX / momentsStore.momentSize.width * 5
    }
    
    public func getCornerRadius(_ proxy: GeometryProxy)  -> CGFloat {
        let minX = abs(proxy.frame(in: .global).minX)
        let radius = minX / 12.5
        return radius >= 25 ? 25 : radius
    }
}
