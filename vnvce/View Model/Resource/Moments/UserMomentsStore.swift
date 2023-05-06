
import SwiftUI
import VNVCECore

class UserMomentsStore: ObservableObject {
    private let momentAPI = MomentAPI()
    
    public let screen: CGRect = UIScreen.main.bounds
    public let navBarHeight: CGFloat = 36
    public let momentSize: CGSize
    
    @Published public var usersWithMoments: [UserWithMoments.V1] = []
    
    @Published public var currentMoment: VNVCECore.Moment.V1.Public?
    
    init() {
        let width = screen.width
        let height = width * 3 / 2
        momentSize = CGSize(width, height)
    }
    
    public func fetchFriendsMoment() async {
        do {
            guard let result = try await momentAPI.fetchFriendsMoment() else {
                return
            }
            
            await MainActor.run {
                self.usersWithMoments = result
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
}
