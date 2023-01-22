
import Foundation
import VNVCECore
import NIO

actor NotificationAPI {
    private let session = URLSession.shared
    private let routes = NotificationRoutes.V1.shared
    private var endpoint = Endpoint.shared
    private let authAPI = AuthAPI()
    private let jsonEncoder = JSONEncoder()
    
    public init() {
        endpoint.run = WebConstants.run
    }
    
}

extension NotificationAPI {
    
    public func registerToken(token: String) async throws {
        let params: [URLQueryItem] = [.init(name: "token", value: token)]
        
        let url = endpoint.makeURL(routes.register, params: params)
        var request = try URLRequest(url: url, method: .post)
        request.setAcceptVersion(.v1)
        request.setClientOS()
        
        _ = try await authAPI.secureTask(request)
        
    }
    
}
