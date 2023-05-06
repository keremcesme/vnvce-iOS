
import Foundation
import VNVCECore

actor MomentAPI {
    private let session = URLSession.shared
    private let routes = MomentRoutes.V1.shared
    private var endpoint = Endpoint.shared
    private let authAPI = AuthAPI()
    private let jsonEncoder = JSONEncoder()
    
    public init() {
        endpoint.run = WebConstants.run
    }
}

// Fetch
extension MomentAPI {
    public func fetchFriendsMoment() async throws -> [UserWithMoments.V1]? {
        let url = endpoint.makeURL(routes.fetchFriendsMoment)
        var request = try URLRequest(url: url, method: .get)
        request.setAcceptVersion(.v1)
        
        return try await authAPI.secureTask(request, decode: [UserWithMoments.V1].self)
    }
}

// Upload
extension MomentAPI {
    public func requestID() async throws -> UUID? {
        let url = endpoint.makeURL(routes.requestID)
        var request = try URLRequest(url: url, method: .get)
        request.setAcceptVersion(.v1)
        
        return try await authAPI.secureTask(request, decode: UUID.self)
    }
    
    public func uploadMoment(_ payload: VNVCECore.UploadMomentPayload.V1) async throws {
        let url = endpoint.makeURL(routes.upload)
        var request = try URLRequest(url: url, method: .post)
        let body = try jsonEncoder.encode(payload)
        request.httpBody = body
        request.setAcceptVersion(.v1)
        request.setContentType(.json)
        
        _ = try await authAPI.secureTask(request, decode: VNVCECore.Moment.V1.Private.self)
    }
}
