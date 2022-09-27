//
//  RelationshipAPI.swift
//  vnvce
//
//  Created by Kerem Cesme on 25.09.2022.
//

import Foundation
import KeychainAccess
import Alamofire
import NIOCore

struct RelationshipAPI {
    static let shared = RelationshipAPI()
    
    private init() {}
 
    public let keychain = Keychain()
    public let urlBuilder = URLBuilder.shared
    public let encoder = JSONParameterEncoder.default
}

// MARK: Public Methods -
extension RelationshipAPI {
    
    public func fetchRelationship(userID: UUID) async throws -> Relationship {
        let result = try await fetchRelationshipTask(userID: userID)
        
        switch result {
        case let .success(response):
            return response
        case let .failure(statusCode):
            if statusCode == .unauthorized {
                let response = try await TokenAPI.shared.retryTask(to: Relationship.self) {
                    switch try await fetchRelationshipTask(userID: userID) {
                    case let .success(response):
                        return response
                    case let .failure(statusCode):
                        throw generateError(code: Int(statusCode.code), description: statusCode.localizedDescription)
                    }
                }
                
                return response
            } else {
                throw generateError(code: Int(statusCode.code), description: statusCode.localizedDescription)
            }
        }
    }
    
    public func relationshipAction(route: RelationshipRoute, relationship: Relationship) async throws -> Relationship {
        let result = try await relationshipActionTask(route, relationship: relationship)

        switch result {
        case let .success(response):
            return response
        case let .failure(statusCode):
            if statusCode == .unauthorized {
                let response = try await TokenAPI.shared.retryTask(to: Relationship.self) {
                    switch try await relationshipActionTask(route, relationship: relationship) {
                    case let .success(response):
                        return response
                    case let .failure(statusCode):
                        throw generateError(code: Int(statusCode.code), description: statusCode.localizedDescription)
                    }
                }
                return response
            } else {
                throw generateError(code: Int(statusCode.code), description: statusCode.localizedDescription)
            }
        }
    }
}

// MARK: Private Methods -
private extension RelationshipAPI {
    
    private func fetchRelationshipTask(userID: UUID) async throws -> Result<Relationship, HTTPStatus> {
        guard let token = try Keychain().get("accessToken") else {
            fatalError()
        }
        
        let url = urlBuilder.relationshipURL(route: .fetch(userID: userID.uuidString), version: .v1)
        
        var headers = HTTPHeaders()
        headers.add(.authorization(bearerToken: token))
        
        let task = AF
            .request(
                url,
                method: .get,
                headers: headers)
            .serializingDecodable(Response<Relationship>.self)
        
        let taskResponse = await task.response
        
        guard let statusCode = taskResponse.response?.statusCode else {
            throw NSError(domain: "Status Code not Available", code: 1)
        }
        
        switch taskResponse.result {
            case let .success(response):
                guard let result = response.result else {
                    throw NSError(domain: "Result is not available", code: 1)
                }
                return .success(result)
            case .failure(_):
                return .failure(HTTPStatus(statusCode: statusCode))
        }
    }
    
    private func relationshipActionTask(_ route: RelationshipRoute, relationship: Relationship) async throws -> Result<Relationship, HTTPStatus> {
        
        guard let token = try Keychain().get("accessToken") else {
            fatalError()
        }
        
        let url = urlBuilder.relationshipURL(route: route, version: .v1)
        
        var headers = HTTPHeaders()
        headers.add(.authorization(bearerToken: token))
        headers.add(.contentType(MIMEType.appJSON))
        
        let task = AF
            .request(
                url,
                method: relationshipActionHTTPMethod(route: route),
                parameters: relationship,
                encoder: encoder,
                headers: headers)
            .serializingDecodable(Response<Relationship>.self)
        
        let taskResponse = await task.response
        
        guard let statusCode = taskResponse.response?.statusCode else {
            throw NSError(domain: "Status Code not Available", code: 1)
        }
        
        switch taskResponse.result {
            case let .success(response):
                guard let result = response.result else {
                    throw NSError(domain: "Result is not available", code: 1)
                }
                return .success(result)
            case .failure(_):
                return .failure(HTTPStatus(statusCode: statusCode))
        }
    }
    
    private func relationshipActionHTTPMethod(route: RelationshipRoute) -> HTTPMethod {
        switch route {
        case .fetch(_):
            return .get
        case let .friend(friendRoute):
            switch friendRoute {
            case let .request(requestRoute):
                switch requestRoute {
                case .send(_), .accept:
                    return .post
                case .undoOrReject:
                    return .delete
                }
            case .remove:
                return .delete
            }
        case let .user(blockRoute):
            switch blockRoute {
            case .block(_):
                return .post
            case .unblock:
                return .delete
            }
        }
    }
    
    // Handle Errors
    private func generateError(code: Int = 1, description: String) -> Error {
        NSError(domain: "RelationshipAPI", code: code, userInfo: [NSLocalizedDescriptionKey: description])
    }
}
