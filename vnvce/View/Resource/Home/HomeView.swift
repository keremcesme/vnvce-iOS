
import SwiftUI
import SwiftUIX
import Introspect
import StoreKit

struct HomeView: View {
    @Environment(\.viewController) public var viewControllerHolder: ViewControllerHolder
    
    @EnvironmentObject private var notificationController: NotificationController
    
    @StateObject public var currentUserVM = CurrentUserViewModel()
    @StateObject public var homeVM = HomeViewModel()
    @StateObject public var userMomentsStore = UserMomentsStore()
    @StateObject public var cameraManager = CameraManager()
    @StateObject public var searchVM = SearchViewModel()
    @StateObject public var contactsVM = ContactsViewModel()
    @StateObject private var storeKit = StoreKitManager()
    
    @State var showSettings = false
    @State var showPaywall = false
    @State var isRecordingScreen = false
    
    @Sendable
    private func commonInit() async {
        await notificationController.requestAuthorization()
        await currentUserVM.fetchProfile()
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Background
                PageView
            }
            .navigationBarHidden(true)
            .environmentObject(currentUserVM)
            .environmentObject(homeVM)
            .environmentObject(userMomentsStore)
            .environmentObject(cameraManager)
            .environmentObject(contactsVM)
            .environmentObject(storeKit)
            .taskInit(commonInit)
//            .onChange(of: cameraManager.image) {
//                showPaywall = $0 != nil
//            }
//            .sheet(isPresented: $showPaywall) {
//                PurchaseView().environmentObject(storeKit)
//            }
        }
    }
    
}
