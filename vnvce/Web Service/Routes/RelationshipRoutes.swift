//
//  RelationshipRoutes.swift
//  vnvce
//
//  Created by Kerem Cesme on 25.09.2022.
//

import Foundation

enum RelationshipRoute {
    case fetch(userID: String)
    case friend(RelationshipFriendRoute)
    case user(RelationshipBlockRoute)
    
    var raw: String {
        let relationship = MainRoute.relationship
        var route = "\(relationship)/"
        switch self {
        case let .fetch(userID):
            route += "fetch/\(userID)"
            return route
        case let .friend(friend):
            route += "friend/\(friend.raw)"
            return route
        case let .user(block):
            route += "user/\(block.raw)"
            return route
        }
    }
}

enum RelationshipFriendRoute {
    case request(RelationshipFriendRequestRoute)
    case remove
    
    var raw: String {
        switch self {
        case let .request(request):
            return "request/\(request.raw)"
        case .remove:
            return "remove"
        }
    }
}

enum RelationshipFriendRequestRoute {
    case send(userID: String)
    case undoOrReject
    case accept
    
    var raw: String {
        switch self {
        case let .send(userID):
            return "send/\(userID)"
        case .undoOrReject:
            return "undo_or_reject"
        case .accept:
            return "accept"
        }
    }
}


enum RelationshipBlockRoute {
    case block(userID: String)
    case unblock
    
    var raw: String {
        switch self {
        case let .block(userID):
            return "block/\(userID)"
        case .unblock:
            return "unblock"
        }
    }
}
