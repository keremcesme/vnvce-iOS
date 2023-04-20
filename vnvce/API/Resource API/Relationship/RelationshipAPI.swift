
import Foundation
import VNVCECore

actor RelationshipAPI {
    private let session = URLSession.shared
    private let routes = RelationshipRoutes.V1.shared
    private var endpoint = Endpoint.shared
    private let authAPI = AuthAPI()
    private let jsonEncoder = JSONEncoder()
    
    public init() {
        endpoint.run = WebConstants.run
    }
}

extension RelationshipAPI {
    
    public func fetch(_ userID: UUID) async throws -> VNVCECore.Relationship.V1? {
        let params: [URLQueryItem] = [.init(name: "user_id", value: userID.uuidString)]
        
        let url = endpoint.makeURL(routes.fetch, params: params)
        
        var request = try URLRequest(url: url, method: .get)
        request.setAcceptVersion(.v1)
        
        return try await authAPI.secureTask(request, decode: VNVCECore.Relationship.V1.self)
    }
    
    public func send(userID: UUID, relationship: VNVCECore.Relationship.V1) async throws -> VNVCECore.Relationship.V1? {
        return try await relationshipAction(userID, relationship, routes.send)
    }
    
    public func accept(userID: UUID, relationship: VNVCECore.Relationship.V1) async throws -> VNVCECore.Relationship.V1? {
        return try await relationshipAction(userID, relationship, routes.accept)
    }
    
    public func undoOrReject(userID: UUID, relationship: VNVCECore.Relationship.V1) async throws -> VNVCECore.Relationship.V1? {
        return try await relationshipAction(userID, relationship, routes.undoOrReject)
    }
    
    public func remove(userID: UUID, relationship: VNVCECore.Relationship.V1) async throws -> VNVCECore.Relationship.V1? {
        return try await relationshipAction(userID, relationship, routes.remove)
    }
    
    private func relationshipAction(
        _ userID: UUID,
        _ relationship: VNVCECore.Relationship.V1,
        _ route: String
    ) async throws -> VNVCECore.Relationship.V1? {
        let params: [URLQueryItem] = [.init(name: "user_id", value: userID.uuidString)]
        
        let url = endpoint.makeURL(route, params: params)
        
        var request = try URLRequest(url: url, method: .post)
        
        let body = try jsonEncoder.encode(relationship)
        
        request.httpBody = body
        request.setContentType(.json)
        request.setAcceptVersion(.v1)
        
        return try await authAPI.secureTask(request, decode: VNVCECore.Relationship.V1.self)
    }
}
