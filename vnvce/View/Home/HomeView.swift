
import SwiftUI
import Introspect

struct HomeView: View {
    @Environment(\.viewController) public var viewControllerHolder: ViewControllerHolder
    
    @StateObject private var homeVM = HomeViewModel()
    @StateObject private var cameraManager = CameraManager()
    
    @StateObject private var searchVM = SearchViewModel()
    
    var body: some View {
        ZStack(alignment: .top){
            BlurView(style: .systemMaterialDark)
                .background {
                    ZStack {
                        Color.black
                        Image(returnBGImage())
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(UIScreen.main.bounds.size)
                    }
                    .animation(.default, value: homeVM.tab)
                }
                .overlay(.black.opacity(0.5))
                .ignoresSafeArea()
            HomePageView
        }
        .environmentObject(cameraManager)
        .environmentObject(homeVM)
    }
    
    func returnBGImage() -> String {
        if let inx = homeVM.testUsers.firstIndex(where: {$0.id.uuidString == homeVM.tab}) {
            return homeVM.testUsers[inx].moment
        } else {
            return "me"
        }
    }
    
    @ViewBuilder
    private var HomePageView: some View {
        GeometryReader { g in
            VStack(spacing: 15){
                TabView(selection: $homeVM.tab){
                    Group {
                        Camera
                            .tag("CAMERA")
                        Moments
                    }
                    .frame(width: UIScreen.main.bounds.width)
                    .introspectScrollView { $0.bounces = false }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: cameraManager.preview.frame.height + 36 + 10)
                BottomView
            }
            .overlay(NavigationBar, alignment: .top)
            .padding(.top, 4)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
    
    @ViewBuilder
    private var Camera: some View {
        GeometryReader { proxy in
            VStack(spacing: 10){
                    HStack {
                        Image("logo")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 24, height: 24)
                            .colorScheme(.dark)
                            .yOffset(2)
                        Text("vnvce")
                            .foregroundColor(.white)
                            .font(.system(size: 36, weight: .heavy, design: .default))
                            .yOffset(-2)
                        Spacer()
                    }
                .frame(height: 36)
                .padding(.horizontal, 20)
                CameraView()
                    .scaleEffect(homeVM.tab == "CAMERA" ? 1 : 0.99)
                    .overlay {
                        if homeVM.tab != "CAMERA" {
                            BlurView(style: .dark)
                                .cornerRadius(25, style: .continuous)
                        }
                    }
                    .animation(.default, value: homeVM.tab)
            }
        }
    }
    
    @ViewBuilder
    private var NavigationBar: some View {
        GeometryReader {
            let height = $0.size.height
            HStack(spacing: 15) {
                Spacer()
                Button {
                    guard let controller = self.viewControllerHolder.value else {
                        return
                    }
                    controller.present {
                        cameraManager.stopSession()
                    } content: {
                        SearchView().environmentObject(searchVM)
                            
                    }
                } label: {
                    BlurView(style: .systemMaterialDark)
                        .frame(width: height, height: height)
                        .clipShape(Circle())
                        .overlay {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.white).opacity(0.9)
                                .font(.system(size: 18, weight: .medium, design: .default))
                        }
                }

                
                
                ZStack {
                    Group {
                        Image("me")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 35, height: 35)
                        BlurView(style: .dark)
                            .frame(width: 36, height: 36)
                        Image("me")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 31, height: 31)
                    }
                    .clipShape(Circle())
                }

            }
        }
        .frame(height: 36)
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private var BottomView: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 15){
                    ShutterButton.id("CAMERA")
                    ForEach(Array(homeVM.testUsers.enumerated()), id: \.element.id) { inx, user in
                        User(inx, user).id(user.id.uuidString)
                    }
                }
                .padding(.horizontal, 200 )
            }
            .onChange(of: homeVM.tab) { id in
                if id == "CAMERA" {
                    cameraManager.startSession()
                } else {
                    cameraManager.stopSession()
                }
                withAnimation {
                    proxy.scrollTo(id, anchor: .center)
                }
            }
        }
        
    }
    
    @ViewBuilder
    private func User(_ inx: Int, _ user: UserTestModel) -> some View {
        Button {
            homeVM.tab = user.id.uuidString
        } label: {
            VStack(spacing: 7) {
                if homeVM.tab == user.id.uuidString {
                    ZStack {
                        Image(user.picture)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 65, height: 65)
                            .clipShape(Circle())
                        BlurView(style: .systemUltraThinMaterialDark)
                            .frame(width: 66, height: 66, alignment: .center)
                            .clipShape(Circle())
                        Circle()
                            .strokeBorder(.white, lineWidth: 6)
                            .foregroundColor(Color.clear)
                            .frame(width: 72, height: 72, alignment: .center)
                    }
                } else {
                    ZStack {
                        Group {
                            Image(user.picture)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 71, height: 71)
                            BlurView(style: .dark)
                                .frame(width: 72, height: 72)
                            Image(user.picture)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 64, height: 64)
                        }
                        .clipShape(Circle())
                    }
                    .overlay(alignment: .topTrailing) {
                        if user.count >= 2 {
                            BlurView(style: .dark)
                                .frame(width: 25, height: 25)
                                .overlay {
                                    Text("\(user.count)")
                                        .foregroundColor(.white)
                                        .tracking(-0.25)
                                        .font(.system(size: 12, weight: .medium, design: .default))
                                }
                                .clipShape(Circle())
                        }
                    }
                }
                Text(user.name)
                    .foregroundColor(.white)
                    .tracking(-0.25)
                    .font(.system(size: 12, weight: .regular, design: .default))
                    .frame(maxWidth: 79.5)
                    .opacity(homeVM.tab == user.id.uuidString ? 0.00001 : 1)
            }
            .animation(.default, value: homeVM.tab)
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var Moments: some View {
        ForEach(Array(homeVM.testUsers.enumerated()), id: \.element.id) { inx, user in
            GeometryReader { proxy in
                VStack(spacing: 10) {
                    HStack {
                        ZStack {
                            Group {
                                Image(user.picture)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 35, height: 35)
                                BlurView(style: .dark)
                                    .frame(width: 36, height: 36)
                                Image(user.picture)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 31, height: 31)
                            }
                            .clipShape(Circle())
                        }
                        Text(user.name)
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .medium, design: .default))
                        Spacer()
                    }
                    .frame(height: 36)
                    .scaleEffect(getScale(proxy: proxy))
                    .opacity(getScale(proxy: proxy))
                    .padding(.horizontal, 20)
                    Image(user.moment)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .cornerRadius(25, style: .continuous)
                        .overlay {
                            if homeVM.tab != user.id.uuidString {
                                BlurView(style: .dark)
                            }
                        }
                        .frame(cameraManager.preview.frame.size)
                        .cornerRadius(25, style: .continuous)
                        .scaleEffect(getScale(proxy: proxy))
                        .animation(.default, value: homeVM.tab)
                }
                
            }
            .tag(user.id.uuidString)
        }
    }
    
    func getScale(proxy: GeometryProxy) -> CGFloat {
        let x = proxy.frame(in: .global).minX
        let diff = abs(x)
        
        let scale: CGFloat = 1 + (cameraManager.preview.frame.width / 4 - diff) / cameraManager.preview.frame.height
        
        return scale > 1.0 ? 1.0 : scale
    }
    
    @ViewBuilder
    private var ShutterButton: some View {
        Button {
            if homeVM.tab == "CAMERA" {
                cameraManager.capturePhoto()
            } else {
                homeVM.tab = "CAMERA"
            }
        } label: {
            ZStack {
                BlurView(style: .systemUltraThinMaterialDark)
                    .frame(width: 66, height: 66, alignment: .center)
                    .clipShape(Circle())
                Circle()
                    .strokeBorder(.white, lineWidth: 6)
                    .foregroundColor(Color.clear)
                    .frame(width: 72, height: 72, alignment: .center)
                    .opacity(homeVM.tab == "CAMERA" ? 1 : 0.1)
                if homeVM.tab != "CAMERA" {
                    Image("Home")
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                }
            }
        }
    }
    
}
