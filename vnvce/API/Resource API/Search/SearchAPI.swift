
import Foundation
import VNVCECore
import NIO

actor SearchAPI {
    private let session = URLSession.shared
    private let routes = SearchRoutes.V1.shared
    private var endpoint = Endpoint.shared
    private let authAPI = AuthAPI()
    private let jsonEncoder = JSONEncoder()
    
    public init() {
        endpoint.run = WebConstants.run
    }
    
}

extension SearchAPI {
    public func searchUser(search text: String, params: VNVCECore.PaginationParams) async throws -> PaginationResponse<User.Public> {
        
        let url = endpoint.makeURL(routes.searchUser, pagination: params)
        
        var request = try URLRequest(url: url, method: .post)
        let body = try jsonEncoder.encode(text)
        request.httpBody = body
        request.setContentType(.json)
        request.setAcceptVersion(.v1)
        
        print(url)
        
        guard let result = try await authAPI.secureTask(request, decode: PaginationResponse<User.Public>.self) else {
            throw NSError(domain: "", code: 1)
        }
        
        return result
    }
}
