
import SwiftUI
import SwiftUIX
import Introspect
import StoreKit

struct HomeView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @Environment(\.viewController) public var viewControllerHolder: ViewControllerHolder
    
    @EnvironmentObject private var notificationController: NotificationController
    
    @StateObject public var keyboardController = KeyboardController()
    
    @StateObject public var currentUserVM = CurrentUserViewModel()
    
    @StateObject public var homeVM = HomeViewModel()
    @StateObject public var cameraManager = CameraManager()
    @StateObject public var searchVM = SearchViewModel()
    @StateObject public var contactsVM = ContactsViewModel()
    @StateObject public var storeKit = StoreKitManager()
    
//    @State var showSettings = false
//    @State var showPaywall = false
//    @State var isRecordingScreen = false
    
    @Sendable
    private func commonInit() async {
        await homeVM.fetchUsersAndTheirMoments()
        await notificationController.requestAuthorization()
        await currentUserVM.fetchProfile()
        
    }
    
    var body: some View {
        NavigationView(content: RootView)
    }
    
    @ViewBuilder
    private func RootView() -> some View {
        ZStack(alignment: .top, content: ContentView)
//            .ignoresSafeArea()
            .navigationBarHidden(true)
            .overlay(MomentOutputViewRoot())
            .environmentObject(keyboardController)
            .environmentObject(currentUserVM)
            .environmentObject(homeVM)
            .environmentObject(cameraManager)
            .environmentObject(contactsVM)
            .environmentObject(storeKit)
            .taskInit(commonInit)
    }
    
    @ViewBuilder
    private func ContentView() -> some View {
        Background
        MainView()
//        PageView
    }
}
