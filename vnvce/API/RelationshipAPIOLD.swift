//
//  RelationshipAPIOLD.swift
//  vnvce
//
//  Created by Kerem Cesme on 25.09.2022.
//

import Foundation
import Alamofire

struct RelationshipAPIOLD {
    static let shared = RelationshipAPIOLD()
    
    private init() {}
 
    public let urlBuilder = URLBuilder.shared
    public let request = AFRequest.shared
    public let secureAPI = SecureAPI.shared
}

// MARK: Public Methods -
extension RelationshipAPIOLD {
    
    public func fetchRelationship(userID: UUID) async throws -> Relationship {
        return try await secureAPI.task({
            try await fetchRelationshipTask(userID: userID)
        }, decode: Relationship.self)
    }
    
    public func relationshipAction(route: RelationshipRoute, relationship: Relationship) async throws -> Relationship {
        return try await secureAPI.task(payload: relationship, {
            try await relationshipActionTask(route, relationship: $0)
        }, decode: Relationship.self)
    }
}

// MARK: Private Methods -
private extension RelationshipAPIOLD {
    
    private func fetchRelationshipTask(userID: UUID) async throws -> Result<Relationship, HTTPStatus> {
        
        return try await request.task(
            url: urlBuilder.relationshipURL(route: .fetch(userID: userID.uuidString), version: .v1),
            method: .get,
            to: Relationship.self)
    }
    
    private func relationshipActionTask(_ route: RelationshipRoute, relationship: Relationship) async throws -> Result<Relationship, HTTPStatus> {
        
        return try await request.task(
            payload: relationship,
            url: urlBuilder.relationshipURL(route: route, version: .v1),
            method: relationshipActionHTTPMethod(route: route),
            to: Relationship.self)
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
    
}
