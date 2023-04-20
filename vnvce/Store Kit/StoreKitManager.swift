
import Foundation
import StoreKit
import VNVCECore

@MainActor
final class StoreKitManager: ObservableObject {
    private let productIDs = ["vnvce.membership.monthly", "vnvce.membership.annual"]
    private let transactionAPI = TransactionAPI()
    
    @Published private(set) public var products = [Product]()
    
    @Published var currentTransactionID: String?
    
    private var transactionListener: Task<Void, Error>?
    
    init() {
        transactionListener = configureTransactionListener()
        Task { [weak self] in
            do {
                try await self?.fetchProducts()
                try await self?.handleUnfinishedTransactions()
                try await self?.fetchActiveSubscriptions()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    deinit {
        transactionListener?.cancel()
    }
}

// MARK: Purchase Product
extension StoreKitManager {
    public func purchase(_ product: Product) async {
        do {
            let userID = UUID(uuidString: "7292217d-90b5-4912-a850-1d90dca9f1f4")!
            let result = try await product.purchase(options: [.appAccountToken(userID)])
            try await handlePurchase(from: result)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func handlePurchase(from result: Product.PurchaseResult) async throws {
        guard case let .success(result) = result else {
            return
        }
        
        let transaction = try verifyTransaction(result)
        self.currentTransactionID = String(transaction.id)
        let t = transaction.convert
        try await transactionAPI.completeTransaction(t)
        await transaction.finish()
        
        print("Purchase was a success, now it's time to verify their purchase")
    }
}

// MARK: Fetch Products
private extension StoreKitManager {
    private func fetchProducts() async throws {
        self.products = try await Product
            .products(for: productIDs)
            .sorted(by: {$0.price < $1.price})
    }
    
    private func handleUnfinishedTransactions() async throws {
        for await result in Transaction.unfinished {
            let transaction = try verifyTransaction(result)
            await transaction.finish()
        }
    }
}

// MARK: Fetch Active Subscriptions
private extension StoreKitManager {
    private func fetchActiveSubscriptions() async throws {
        for product in products {
            let result = await product.currentEntitlement
            if let result {
                let transaction = try verifyTransaction(result)
                if transaction.productType == .autoRenewable {
                    // Active Subscription is here
                    print("ID: \(transaction.id)")
                    self.currentTransactionID = String(transaction.id)
                }
            }
        }
    }
}

// MARK: Transactions Listener
private extension StoreKitManager {
    private func configureTransactionListener() -> Task<Void, Error> {
        return .detached(priority: .background) { @MainActor [weak self] in
            do {
                for await result in Transaction.updates {
                    let verifiedTransaction = try self?.verifyTransaction(result)
                    await verifiedTransaction?.finish()
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

fileprivate typealias RenewalInfo = Product.SubscriptionInfo.RenewalInfo

/// `VerificationResult<T>`
fileprivate typealias TransactionResult = VerificationResult<Transaction>
fileprivate typealias RenewalResult = VerificationResult<RenewalInfo>

private extension StoreKitManager {
    private func verifyTransaction(_ result: TransactionResult) throws -> Transaction {
        switch result {
        case .unverified:
            throw NSError(domain: "Failed Verification", code: 1)
        case let .verified(transaction):
            
            return transaction
        }
    }
    
    private func verifyRenewal(_ result: RenewalResult) throws -> RenewalInfo {
        switch result {
        case .unverified:
            throw NSError(domain: "Failed Verification", code: 1)
        case let .verified(renewalInfo):
            return renewalInfo
        }
    }
}

extension Transaction {
    var convert: AppStoreTransaction.V1 {
        return .init(
            id: String(self.id),
            originalID: String(self.originalID),
            appAccountToken: self.appAccountToken!,
            productID: self.productID,
            appBundleID: self.appBundleID,
            purchaseDate: self.purchaseDate.timeIntervalSince1970,
            originalPurchaseDate: self.originalPurchaseDate.timeIntervalSince1970,
            purchasedQuantity: self.purchasedQuantity,
            productType: .autoRenewable,
            ownershipType: .purchased,
            webOrderLineItemID: self.webOrderLineItemID,
            subscriptionGroupID: self.subscriptionGroupID,
            expirationDate: self.expirationDate?.timeIntervalSince1970,
            isUpgraded: self.isUpgraded,
            offerType: nil,
            offerID: self.offerID,
            revocationDate: self.revocationDate?.timeIntervalSince1970,
            revocationReason: nil,
            signedDate: self.signedDate.timeIntervalSince1970)
    }
}
