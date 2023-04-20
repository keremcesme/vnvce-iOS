
import SwiftUI
import VNVCECore

class UserProfileViewModel: ObservableObject {
    private let relationshipAPI = RelationshipAPI()
    
    @Published private(set) public var user: User.Public
    
    @Published public var relationshipIsUpdating: Bool = true
    @Published public var relationship: VNVCECore.Relationship.V1?
    
    @Published public var showRelationshipAlert: Bool = true
    
    @Published public var profilePictureImage: UIImage?
    
    public init(_ user: User.Public, profilePictureImage: UIImage?) {
        self.user = user
        self.profilePictureImage = profilePictureImage
    }
    
    public func fetchRelationship() async {
        do {
            self.relationship = try await relationshipAPI.fetch(user.id)
            self.relationshipIsUpdating = false
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func sendFriendRequest() async {
        self.relationshipIsUpdating = true
        do {
            if let relationship {
                self.relationship = try await relationshipAPI.send(userID: user.id, relationship: relationship)
            }
            
            self.relationshipIsUpdating = false
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func acceptFriendRequest() async {
        self.relationshipIsUpdating = true
        do {
            if let relationship {
                self.relationship = try await relationshipAPI.accept(userID: user.id, relationship: relationship)
            }
            
            self.relationshipIsUpdating = false
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func undoOrRejectFriendRequest() async {
        self.relationshipIsUpdating = true
        do {
            if let relationship {
                self.relationship = try await relationshipAPI.undoOrReject(userID: user.id, relationship: relationship)
            }
            
            self.relationshipIsUpdating = false
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func removeFriend() async {
        self.relationshipIsUpdating = true
        do {
            if let relationship {
                self.relationship = try await relationshipAPI.remove(userID: user.id, relationship: relationship)
            }
            
            self.relationshipIsUpdating = false
        } catch {
            print(error.localizedDescription)
        }
    }
    
}
