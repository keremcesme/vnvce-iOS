
import SwiftUI
import SwiftUIX
import VNVCECore


struct UserMomentsView: View {
    @EnvironmentObject private var homeVM: HomeViewModel
    
    @Binding private var vm: UserAndTheirMoments
    
    public var index: Int
    
    init(_ index: Int, _ vm: Binding<UserAndTheirMoments>) {
        self.index = index
        self._vm = vm
    }
    
    var body: some View {
        GeometryReader(content: GeometryReaderContent)
            .tag(vm.user.detail.id.uuidString)
    }
    
    @ViewBuilder
    private func GeometryReaderContent(_ proxy: GeometryProxy) -> some View {
        MomentView(proxy, index, $vm)
    }
}

extension UserMomentsView {
    struct MomentView: View {
        @EnvironmentObject private var homeVM: HomeViewModel
        
        @Binding private var vm: UserAndTheirMoments
        
        private var index: Int
        private var proxy: GeometryProxy
        
        public init(
            _ proxy: GeometryProxy,
            _ index: Int,
            _ vm: Binding<UserAndTheirMoments>
        ) {
            self.proxy = proxy
            self.index = index
            self._vm = vm
        }
        
        private var setScale: CGFloat {
            let minX = abs(proxy.frame(in: .global).minX)
            return abs(1 - minX / homeVM.contentSize.width / 4)
        }
        
        private var setOpacity: CGFloat {
            let minX = abs(proxy.frame(in: .global).minX)
            return 1 - minX / homeVM.contentSize.width * 1.5
        }
        
        private var setBlurOpacity: CGFloat {
            let minX = abs(proxy.frame(in: .global).minX)
            return minX / homeVM.contentSize.width * 2
        }
        
        private var setCornerRadius: CGFloat {
            let minX = abs(proxy.frame(in: .global).minX)
            let radius = minX / 15
            return radius >= 15 ? 15 : radius
        }
        
        var body: some View {
            Group {
                switch UIDevice.current.hasNotch() {
                case true: NotchView
                case false: NonNotchView
                }
            }
        }
        
        @ViewBuilder
        private var NotchView: some View {
            VStack(spacing: 10){
                NavigationBar($vm)
                    .opacity(setOpacity)
                    .scaleEffect(setScale, anchor: .leading)
                MomentView
                    .frame(homeVM.contentSize)
                    .cornerRadius(setCornerRadius)
                    .scaleEffect(setScale)
            }
        }
        
        @ViewBuilder
        private var NonNotchView: some View {
            ZStack(alignment: .topLeading){
                MomentView
                Group {
                    GradientForNoneNotch
                    NavigationBar($vm)
                }
                .opacity(setOpacity)
            }
            .cornerRadius(setCornerRadius)
            .scaleEffect(setScale)
        }
        
        @ViewBuilder
        private var GradientForNoneNotch: some View {
            LinearGradient(colors: [.black.opacity(0.5), .clear], startPoint: .top, endPoint: .bottom)
                .frame(height: UIDevice.current.statusBarHeight() + homeVM.navBarHeight + 10)
        }
        
        @ViewBuilder
        private var MomentView: some View {
            ZStack(alignment: .bottom) {
                ImageView(
                    minX: abs(proxy.frame(in: .global).minX),
                    index: index,
                    vm:  $vm,
                    momentVM: $vm.moments[vm.currentMomentIndex])
                if vm.moments.count > 1 {
                    HStack(spacing: 2){
                        ForEach(Array(vm.moments.enumerated()), id: \.offset) { inx in
                            Capsule()
                                .foregroundColor(.white)
                                .opacity(inx.offset == vm.currentMomentIndex ? 1 : 0.55)
                                .frame(height: 2)
                                .shadow(2)
                        }
                    }
                    .padding(2)
                    .background(.ultraThinMaterial, in: Capsule())
                    .colorScheme(.dark)
                    .padding(.horizontal, 7.5)
                    .padding(.bottom, 7.5)
                }
            }
        }
        
    }
}

//struct UserMomentsView: View {
//
//    @EnvironmentObject public var currentUserVM: CurrentUserViewModel
//    @EnvironmentObject public var homeVM: HomeViewModel
//
//    @StateObject public var momentsVM: UserMomentsViewModel
//
//    public var index: Int
//
//    public var usersAndTheirMoments: UserAndTheirMoments
//
//    public init(_ index: Int, _ usersAndTheirMoments: UserAndTheirMoments) {
//        self.index = index
//        self.usersAndTheirMoments = usersAndTheirMoments
//        self._momentsVM = StateObject(wrappedValue: UserMomentsViewModel(first: usersAndTheirMoments.moments[0]))
//    }
//    
//    var body: some View {
//
//        GeometryReader(content: ContentView)
//            .tag(usersAndTheirMoments.owner.detail.id.uuidString)
////            .onChange(of: homeVM.currentTab) {
////                if $0 == usersAndTheirMoments.owner.detail.id.uuidString {
////                    momentsStore.currentMoment = momentsVM.currentMoment
////                }
////            }
//            .taskInit {
//                Task.detached(priority: .medium) {
//                    await homeVM.downloadOtherMomentImages(usersAndTheirMoments.owner.detail.id)
//                }
//            }
//            .onChange(of: momentsVM.currentMomentIndex) {
//                let currentMoment = usersAndTheirMoments.moments[$0]
//                momentsVM.currentMoment = currentMoment
//            }
//            .onTapGesture {
//                UIImpactFeedbackGenerator(style: .light).impactOccurred()
//                momentsVM.currentMomentIndex = 1
//            }
//    }
//
//    @ViewBuilder
//    private func ContentView(_ proxy: GeometryProxy) -> some View {
//        switch UIDevice.current.hasNotch() {
//        case true: NotchView(proxy)
//        case false: NonNotchView(proxy)
//        }
//    }
//
//    @ViewBuilder
//    private func NotchView(_ proxy: GeometryProxy) -> some View {
//        VStack(alignment: .leading, spacing: 10) {
//            NavigationBar
//                .opacity(getOpacity(proxy))
//                .scaleEffect(getScale(proxy), anchor: .leading)
//            MomentView(proxy)
////                .cornerRadius(10, style: .circular)
//                .cornerRadius(getCornerRadius(proxy), style: .circular)
//                .scaleEffect(getScale(proxy))
//        }
//    }
//
//    @ViewBuilder
//    private func NonNotchView(_ proxy: GeometryProxy) -> some View {
//        ZStack(alignment: .topLeading){
//            MomentView(proxy)
//            Group {
//                LinearGradient(colors: [.black.opacity(0.5), .clear], startPoint: .top, endPoint: .bottom)
//                    .frame(height: UIDevice.current.statusBarHeight() + homeVM.navBarHeight + 10)
//                NavigationBar
//            }
//            .opacity(getOpacity(proxy))
//        }
//        .cornerRadius(getCornerRadius(proxy), style: .circular)
//        .scaleEffect(getScale(proxy))
//        .ignoresSafeArea()
//    }
//
//    @ViewBuilder
//    private func MomentView(_ proxy: GeometryProxy) -> some View {
//        ZStack(alignment: .bottom) {
//            ImageView(minX: abs(proxy.frame(in: .global).minX),
//                      index: index,
//                      userWithMoments: usersAndTheirMoments,
//                      momentsVM: momentsVM)
//            if usersAndTheirMoments.moments.count > 1 {
//                HStack(spacing: 2){
//                    ForEach(Array(usersAndTheirMoments.moments.enumerated()), id: \.offset) { inx in
//                        Capsule()
//                            .foregroundColor(.white)
//                            .opacity(inx.offset == 0 ? 1 : 0.55)
//                            .frame(height: 2)
//                            .shadow(2)
//                    }
//                }
//                .padding(2)
//                .background(.ultraThinMaterial, in: Capsule())
//                .colorScheme(.dark)
//                .padding(.horizontal, 7.5)
//                .padding(.bottom, 7.5)
//            }
//
//        }
//    }
//}
//
//extension UserMomentsView {
//
//    public func getScale(_ proxy: GeometryProxy) -> CGFloat {
//        let minX = abs(proxy.frame(in: .global).minX)
//        return abs(1 - minX / homeVM.contentSize.width / 4)
//    }
//
//    public func getOpacity(_ proxy: GeometryProxy) -> CGFloat {
//        let minX = abs(proxy.frame(in: .global).minX)
//        return 1 - minX / homeVM.contentSize.width * 1.5
//    }
//
//    private func blur(_ proxy: GeometryProxy) -> Bool {
//        return true
//    }
//
//    private func getBlur(_ proxy: GeometryProxy) -> CGFloat {
//        if homeVM.touchesBegan {
//            return 50
//        } else {
//            let minX = abs(proxy.frame(in: .global).minX)
//
//            return minX != 0 ? 50 : 0
//        }
//
////        let value = minX / homeVM.contentSize.width * 200
////
////        return value <= 50 ? value : 50
//    }
//
//    private func getBlurOpacity2(_ proxy: GeometryProxy) -> CGFloat {
//        let minX = abs(proxy.frame(in: .global).minX)
//        return minX / homeVM.contentSize.width * 5
//    }
//
//    public func getCornerRadius(_ proxy: GeometryProxy)  -> CGFloat {
//        let minX = abs(proxy.frame(in: .global).minX)
//        let radius = minX / 15
//        return radius >= 15 ? 15 : radius
//
////        if UIDevice.current.hasNotch() {
////            return radius >= 25 ? 25 : (radius < 10 ? 10 : radius)
////        } else {
////            return radius >= 25 ? 25 : radius
////        }
//
//    }
//}
