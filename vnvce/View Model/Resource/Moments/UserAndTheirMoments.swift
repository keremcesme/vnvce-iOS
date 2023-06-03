
import SwiftUI
import VNVCECore

struct UserAndTheirMoments{
    public var user: PublicUser
    
    public var moments: [MomentViewModel]
    
    public var currentMomentIndex: Int = 0
    public var currentMomentID: UUID
//    @Published public var currentMoment: PublicMoment
    
    init(user: PublicUser, moments: [MomentViewModel]) {
        self.user = user
        self.moments = moments
        self.currentMomentID = moments.first!.id
    }
    
}

extension UserWithMoments.V1 {
    var convertToUsersAndTheirMoments: UserAndTheirMoments {
        return .init(
            user: self.owner.convertToPublicUser,
            moments: self.moments.convertToMomentVM)
    }
}

extension Array where Element == UserWithMoments.V1 {
    var convertToUsersAndTheirMoments: [UserAndTheirMoments] {
        return self.lazy.map { value in
            value.convertToUsersAndTheirMoments
        }
    }
}
