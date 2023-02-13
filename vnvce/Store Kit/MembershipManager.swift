
import Foundation
import StoreKit

fileprivate typealias PurchaseResult = Product.PurchaseResult
fileprivate typealias TransactionListener = Task<Void, Error>

public enum PurchaseError: LocalizedError {
    case failedVerification
    case system(Error)
    
    public var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "User transaction verification failed"
        case let .system(error):
            return error.localizedDescription
        }
    }
}

public enum PurchaseAction: Equatable {
    case successful
    case failed(PurchaseError)
    
    public static func == (lhs: PurchaseAction, rhs: PurchaseAction) -> Bool {
        switch (lhs, rhs) {
        case (.successful, .successful):
            return true
        case (let .failed(lhsErr), let .failed(rhsErr)):
            return lhsErr.localizedDescription == rhsErr.localizedDescription
        default:
            return false
        }
    }
}

@MainActor
final class MembershipManager: ObservableObject {
    private let productIDs = [
        "vnvce.membership.monthly",
        "vnvce.membership.annual"
    ]
    
    @Published private(set) public var products = [Product]()
    
    @Published private(set) public var action: PurchaseAction? {
        didSet {
            switch action {
            case .failed:
                hasError = true
            default:
                hasError = false
            }
        }
    }
    
    @Published public var hasError: Bool = false
    
    @Published public var currentTransactionID: UInt64 = 0 {
        didSet {
            showRefundRequestSheet = currentTransactionID != 0
        }
    }
    
    @Published public var showRefundRequestSheet: Bool = false
    
    private var error: PurchaseError? {
        switch action {
        case let .failed(error):
            return error
        default:
            return nil
        }
    }
    
    private var transactionListener: TransactionListener?
    
    init() {
        transactionListener = configureTransactionListener()
        Task { [weak self] in
            await self?.retriveProducts()
        }
    }
    
    deinit {
        transactionListener?.cancel()
    }
    
    public func purchase(_ product: Product) async {
        do {
            let userID = UUID(uuidString: "BA2E032B-0DAA-453E-93E7-1002591B4B58")!
            let result = try await product.purchase(options: [.appAccountToken(userID)])
            try await handlePurchase(from: result)
        } catch let error {
            action = .failed(.system(error))
            print(error.localizedDescription)
        }
    }
    
    public func beginRefundProcess() async {
        
        for product in products {
            guard let state = await product.currentEntitlement else { continue }
            do {
                let transaction = try self.checkVerified(state)
                currentTransactionID = transaction.id
                return
            } catch {
                print(error.localizedDescription)
            }
            
        }
        
        let transaction: Transaction? = await {
            for productID in productIDs {
                guard case let .verified(transaction) = await Transaction.latest(for: productID) else {
                    continue
                }
                return transaction
            }
            return nil
        }()
        
        currentTransactionID = transaction?.id ?? 0
    }
    
    private func reset() {
        action = nil
    }
}

private extension MembershipManager {
    private func configureTransactionListener() -> TransactionListener {
        Task.detached(priority: .background) { @MainActor [weak self] in
            do {
                for await result in Transaction.unfinished {
                    let transaction = try self?.checkVerified(result)
                    self?.action = .successful
                    await transaction?.finish()
                }
                
                for await result in Transaction.updates {
                    let transaction = try self?.checkVerified(result)
                    self?.action = .successful
                    await transaction?.finish()
                }
            } catch let error {
                self?.action = .failed(.system(error))
                print(error.localizedDescription)
            }
        }
    }
    
    private func retriveProducts() async {
        do {
            let products = try await Product.products(for: productIDs)
            self.products = products.sorted(by: {$0.price > $1.price})
            
            print("Currency Code")
            print(self.products[1].priceFormatStyle.currencyCode)
            print("Display Price")
            print(self.products[1].displayPrice)
            print("Price")
            print(self.products[1].price)
            print("-------------------")
            
            try await checkPurchased()
            for await result in Transaction.currentEntitlements {
                let transaction = try self.checkVerified(result)
                print(transaction.id)
                print(transaction.productID)
//                if transaction.revocationDate == nil {
//                    if let expirationDate = transaction.expirationDate {
//                        if expirationDate > Date() {
//                            print("Active")
//                        }
//                    }
//                }
            }
        } catch let error {
            action = .failed(.system(error))
            print(error.localizedDescription)
        }
    }
    
    private func checkUnfinished() async throws {
        for await result in Transaction.unfinished {
            let transaction = try self.checkVerified(result)
            print("Finished")
            await transaction.finish()
        }
    }
    
    private func checkPurchased() async throws {
        for product in products {
            guard let result = await Transaction.latest(for: product.id) else { continue }
            let transaction = try self.checkVerified(result)
//            print(transaction.id)
//            print(transaction.productID)
//            if transaction.revocationDate == nil {
//                if let expirationDate = transaction.expirationDate {
//                    if expirationDate > Date() {
//                        print("Active")
//                    }
//                }
//            }
            
            return
        }
//
//        print("NO Transactions")
        
//        for product in products {
//            if let latest = await product.latestTransaction {
//                let transaction = try self.checkVerified(latest)
//                print("Current Subscription 1: \(transaction.productID)")
//                await transaction.finish()
//            }
//
//            guard let state = await product.currentEntitlement else { continue }
//            let transaction = try self.checkVerified(state)
//            print("Current Subscription 2: \(transaction.productID)")
//            await transaction.finish()
//        }
    }
    
    private func handlePurchase(from result: PurchaseResult) async throws {
        switch result {
        case let .success(verification):
            let transaction = try checkVerified(verification)
            action = .successful
           
            await transaction.finish()
            print("Purchase was a success, now it's time to verify their purchase")
        case .userCancelled:
            print("The user hit cancel before their transaction started")
        case .pending:
            print("The user needs to complete some action on their account before they can complete purchase")
        default:
            print("Unknown error")
        }
    }
    
    private func checkVerified(_ result: VerificationResult<Transaction>) throws -> Transaction {
        switch result {
        case .unverified:
            print("Burasi")
            throw PurchaseError.failedVerification
        case let .verified(transaction):
            let type = transaction.productType
            return transaction
        }
    }
}
