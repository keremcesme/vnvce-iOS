
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
        
        guard let result = try await authAPI.secureTask(request, decode: PaginationResponse<User.Public>.self) else {
            throw NSError(domain: "", code: 1)
        }
        
        return result
    }
    
    func searchFromContacts(_ phoneNumbers: [String]) async throws -> [User.Public] {
        let url = endpoint.makeURL(routes.fromContacts)
        var request = try URLRequest(url: url, method: .post)
        let payload = SearchFromContactsPayload.V1(phoneNumbers)
        let body = try jsonEncoder.encode(payload)
        request.httpBody = body
        request.setContentType(.json)
        request.setAcceptVersion(.v1)
        
        guard let result = try await authAPI.secureTask(request, decode: [User.Public].self) else {
            throw NSError(domain: "", code: 1)
        }
        
        return result
    }
}
