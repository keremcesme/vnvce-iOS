
import SwiftUI
import SwiftUIX
import Introspect
import StoreKit

#if DEBUG
    let certificate = "StoreKitTestCertificate"
#else
    let certificate = "AppleIncRootCertificate"
#endif

//typealias PurchaseResult = Product.PurchaseResult



struct HomeView: View {
    @Environment(\.viewController) public var viewControllerHolder: ViewControllerHolder
    
    @EnvironmentObject private var notificationController: NotificationController
    
    @StateObject public var currentUserVM = CurrentUserViewModel()
    
    @StateObject public var homeVM = HomeViewModel()
    
    @StateObject public var cameraManager = CameraManager()
    
    @StateObject public var searchVM = SearchViewModel()
    
    @StateObject public var contactsVM = ContactsViewModel()
    
    @StateObject private var membershipManager = MembershipManager()
    
    @State var showSettings = false
    
    @Sendable
    private func commonInit() async {
        await notificationController.requestAuthorization()
        await currentUserVM.fetchProfile()
    }
    var body: some View {
        ZStack(alignment: .top){
            Background
            PageView
        }
        .environmentObject(cameraManager)
        .environmentObject(homeVM)
        .environmentObject(contactsVM)
        .taskInit(commonInit)
        .overlay {
            if cameraManager.image != nil {
                Color.black
                    .overlay {
                        VStack(spacing: 20) {
                            Text("Products")
                            ForEach(self.membershipManager.products.reversed()) { product in
                                Button {
                                    Task {
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        await membershipManager.purchase(product)
                                    }
                                } label: {
                                    Text("\(product.displayPrice) - \(product.displayName)")
                                }
                            }
                            
                            Button {
                                Task {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    await membershipManager.beginRefundProcess()
                                }
                            } label: {
                                Text("Begin Refund")
                            }
                            
                            Button {
                                Task {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    showSettings = true
                                }
                            } label: {
                                Text("Show Subs")
                            }
                        }
                    }
                    .ignoresSafeArea()
                    .onTapGesture {
                        cameraManager.image = nil
                        cameraManager.startSession()
                    }
            }
        }
        .refundRequestSheet(for: membershipManager.currentTransactionID, isPresented: $membershipManager.showRefundRequestSheet)
        .manageSubscriptionsSheet(isPresented: $showSettings)
    }
    
}
