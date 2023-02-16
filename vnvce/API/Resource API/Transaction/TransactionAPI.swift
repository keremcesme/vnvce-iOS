
import Foundation
import VNVCECore

actor TransactionAPI {
    private let session = URLSession.shared
    private let routes = TransactionRoutes.V1.shared
    private var endpoint = Endpoint.shared
    private let authAPI = AuthAPI()
    private let jsonEncoder = JSONEncoder()
    
    public init() {
        endpoint.run = WebConstants.run
//        endpoint.run = .dev("3f6f-78-135-94-35.ngrok.io")
    }
    
}

extension TransactionAPI {
    public func completeTransaction(_ transaction: AppStoreTransaction.V1) async throws {
        let body = try jsonEncoder.encode(transaction)
//        let url = endpoint.makeURL(routes.transaction)
        let url = URL(string: "https://3f6f-78-135-94-35.ngrok.io/api/membership/transaction")!
        var request = try URLRequest(url: url, method: .post)
        request.setAcceptVersion(.v1)
        request.setClientOS()
        request.httpBody = body
        request.setContentType(.json)
        
        _ = try await authAPI.secureTask(request)
    }
}
