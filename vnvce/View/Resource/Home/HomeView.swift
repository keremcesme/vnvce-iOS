
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
    
//    @StateObject private var membershipManager = MembershipManager()
    @StateObject private var storeKit = StoreKitManager()
    
    @State var showSettings = false
    
    @State var showPaywall = false
    
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
        .environmentObject(storeKit)
        .taskInit(commonInit)
        .onChange(of: cameraManager.image) {
            showPaywall = $0 != nil
        }
        .sheet(isPresented: $showPaywall) {
            PurchaseView().environmentObject(storeKit)
        }
//        .refundRequestSheet(for: membershipManager.currentTransactionID, isPresented: $membershipManager.showRefundRequestSheet)
//        .manageSubscriptionsSheet(isPresented: $showSettings)
    }
    
}

//    .overlay {
//        if cameraManager.image != nil {
//            Color.black
//                .overlay {
//                    VStack(spacing: 20) {
//                        Group {
//                            if let status = membershipManager.currrentStatus {
//                                Text("Renewal State")
//                                if #available(iOS 15.4, *) {
//                                    Text(status.localizedDescription)
//                                        .foregroundColor(.white)
//                                } else {
//                                    // Fallback on earlier versions
//                                }
//                            }
//
//                            Text("Transaction ID")
//                            Text(membershipManager.transactionID)
//                                .foregroundColor(.white)
//                        }
//
//                        Text("Products")
//                        ForEach(self.membershipManager.products.reversed()) { product in
//                            Button {
//                                Task {
//                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
//                                    await membershipManager.purchase(product)
//                                }
//                            } label: {
//                                Text("\(product.displayPrice) - \(product.displayName)")
//                            }
//                        }
//
//                        Button {
//                            Task {
//                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
//                                await membershipManager.beginRefundProcess()
//                            }
//                        } label: {
//                            Text("Begin Refund")
//                        }
//
//                        Button {
//                            Task {
//                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
//                                showSettings = true
//                            }
//                        } label: {
//                            Text("Show Subs")
//                        }
//                    }
//                }
//                .ignoresSafeArea()
//                .onTapGesture {
//                    cameraManager.image = nil
//                    cameraManager.startSession()
//                }
//        }
//    }
