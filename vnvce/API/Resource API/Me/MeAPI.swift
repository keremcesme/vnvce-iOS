
import Foundation
import VNVCECore
import NIO

actor MeAPI {
    private let session = URLSession.shared
    private let routes = MeRoutes.V1.shared
    private var endpoint = Endpoint.shared
    private let authAPI = AuthAPI()
    private let jsonEncoder = JSONEncoder()
    
    public init() {
        endpoint.run = WebConstants.run
    }
}

extension MeAPI {
    public func profile() async throws -> User.Private? {
        let url = endpoint.makeURL(routes.profile)
        var request = try URLRequest(url: url, method: .get)
        request.setAcceptVersion(.v1)
        
        return try await authAPI.secureTask(request, decode: User.Private.self)
    }
    
    public func editDisplayName(_ displayName: String?) async throws {
        let url = endpoint.makeURL(routes.editDisplayName)
        var request = try URLRequest(url: url, method: .patch)
        let payload = EditDisplayNamePayload.V1(displayName)
        let body = try jsonEncoder.encode(payload)
        request.httpBody = body
        request.setContentType(.json)
        request.setAcceptVersion(.v1)
        
        _ = try await authAPI.secureTask(request, decode: HTTPStatus.self)
    }
    
    public func editBiography(_ biography: String?) async throws {
        let url = endpoint.makeURL(routes.editBiography)
        var request = try URLRequest(url: url, method: .patch)
        let payload = EditBiographyPayload.V1(biography)
        let body = try jsonEncoder.encode(payload)
        request.httpBody = body
        request.setContentType(.json)
        request.setAcceptVersion(.v1)
        
        _ = try await authAPI.secureTask(request, decode: HTTPStatus.self)
    }
    
    public func editProfilePicture(_ payload: VNVCECore.EditProfilePicturePayload.V1) async throws {
        let url = endpoint.makeURL(routes.editProfilePicture)
        var request = try URLRequest(url: url, method: .patch)
        let body = try jsonEncoder.encode(payload)
     
        request.httpBody = body
        request.setContentType(.json)
        request.setAcceptVersion(.v1)
        
        _ = try await authAPI.secureTask(request)
    }
}
