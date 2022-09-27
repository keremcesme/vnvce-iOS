//
//  Relationship.swift
//  vnvce
//
//  Created by Kerem Cesme on 25.09.2022.
//

import Foundation

enum Relationship: Codable, Equatable {
    case nothing
    case friend(friendshipID: UUID)
    case friendRequestSubmitted(requestID: UUID)
    case friendRequestReceived(requestID: UUID)
    case targetUserBlocked
    case blocked(blockID: UUID)
}

enum RelationshipRaw: Equatable {
    case nothing
    case friend
    case friendRequestSubmitted
    case friendRequestReceived
    case targetUserBlocked
    case blocked
}

extension Relationship {
    var rawString: String {
        switch self {
        case .nothing:
            return "Nothing"
        case .friend(_):
            return "Friend"
        case .friendRequestSubmitted(_):
            return "Friend Request Submitted"
        case .friendRequestReceived(_):
            return "Friend Request Received"
        case .targetUserBlocked:
            return "Target User Blocked"
        case .blocked(_):
            return "Blocked"
        }
    }
}

extension Relationship {
    var raw: RelationshipRaw {
        switch self {
        case .nothing:
            return .nothing
        case .friend(_):
            return .friend
        case .friendRequestSubmitted(_):
            return .friendRequestSubmitted
        case .friendRequestReceived(_):
            return .friendRequestReceived
        case .targetUserBlocked:
            return .targetUserBlocked
        case .blocked(_):
            return .blocked
        }
    }
}

extension RelationshipRaw {
    var temporary: Relationship {
        let id = UUID()
        switch self {
        case .nothing:
            return .nothing
        case .friend:
            return .friend(friendshipID: id)
        case .friendRequestSubmitted:
            return .friendRequestSubmitted(requestID: id)
        case .friendRequestReceived:
            return .friendRequestReceived(requestID: id)
        case .targetUserBlocked:
            return .targetUserBlocked
        case .blocked:
            return .blocked(blockID: id)
        }
    }
}
