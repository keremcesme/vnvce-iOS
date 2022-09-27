//
//  UserProfileViewModel.swift
//  vnvce
//
//  Created by Kerem Cesme on 25.09.2022.
//

import SwiftUI

@MainActor
class UserProfileViewModel: ObservableObject {
    
//    private let userAPI = UserAPI.shared
    private let relationshipAPI = RelationshipAPI.shared
    
    @Published public private(set) var user: User.Public
    
    @Published private(set) public var relationship: Relationship?
    @Published private(set) public var relationshipIsUpdating: Bool = false
    @Published public var showUpdateRelationshipAlert: Bool = false
    
    init(user: User.Public){
        self.user = user
    }
    
    public func fetchRelationship() async {
        await fetchRelationshipTask()
    }
    
    public func sendFriendRequest() async {
        let route: RelationshipRoute = .friend(.request(.send(userID: user.id.uuidString)))
        let targetRelationship: Relationship = RelationshipRaw.friendRequestSubmitted.temporary
        await relationshipAction(route, from: self.relationship, to: targetRelationship)
    }
    
    public func undoOrRejectFriendRequest() async {
        let route: RelationshipRoute = .friend(.request(.undoOrReject))
        let targetRelationship: Relationship = RelationshipRaw.nothing.temporary
        await relationshipAction(route, from: self.relationship, to: targetRelationship)
    }

    public func acceptFriendRequest() async {
        let route: RelationshipRoute = .friend(.request(.accept))
        let targetRelationship: Relationship = RelationshipRaw.friend.temporary
        await relationshipAction(route, from: self.relationship, to: targetRelationship)
    }

    public func removeFriend() async {
        let route: RelationshipRoute = .friend(.remove)
        let targetRelationship: Relationship = RelationshipRaw.nothing.temporary
        await relationshipAction(route, from: self.relationship, to: targetRelationship)
    }

    public func blockUser() async {
        let route: RelationshipRoute = .user(.block(userID: user.id.uuidString))
        let targetRelationship: Relationship = RelationshipRaw.blocked.temporary
        await relationshipAction(route, from: self.relationship, to: targetRelationship)
    }

    public func unblockUser() async {
        let route: RelationshipRoute = .user(.unblock)
        let targetRelationship: Relationship = RelationshipRaw.nothing.temporary
        await relationshipAction(route, from: self.relationship, to: targetRelationship)
    }
}

private extension UserProfileViewModel {
    private func fetchRelationshipTask() async {
        if Task.isCancelled { return }
        do {
            let relationship = try await relationshipAPI.fetchRelationship(userID: user.id)
            if Task.isCancelled { return }
            await MainActor.run {
                self.relationship = relationship
            }
        } catch {
            if Task.isCancelled { return }
            print(error.localizedDescription)
        }
    }
    
    private func relationshipAction(_ route: RelationshipRoute, from: Relationship?, to: Relationship) async {
        guard let relationship = from, !relationshipIsUpdating else {
            return
        }
        
        relationshipIsUpdating = true
        
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        self.relationship = to
        
        await relationshipActionTask(route, relationship: relationship)
        
        relationshipIsUpdating = false
    }
    
    private func relationshipActionTask(_ route: RelationshipRoute, relationship: Relationship) async {
        if Task.isCancelled { return }
        do {
            let newRelationship = try await relationshipAPI.relationshipAction(route: route, relationship: relationship)
            if Task.isCancelled { return }
            await MainActor.run {
                self.relationship = newRelationship
            }
        } catch {
            if Task.isCancelled { return }
            print("❌ [THROW] UserProfileViewModel.relationshipActionTask()")
            print("⚠️ [DESCRIPTION] The user relationship changed during the task. Updating relationship…")
            await fetchRelationshipTask()
            showUpdateRelationshipAlert = true
            print("✅ [FIX] UserProfileViewModel.fetchRelationshipTask()")
        }
    }
}
