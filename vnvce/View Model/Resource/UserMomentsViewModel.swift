
import SwiftUI
import VNVCECore

class UserMomentsViewModel: ObservableObject {
    
    @Published public var currentMomentIndex: Int = 0
    @Published public var currentMoment: VNVCECore.Moment.V1
    
    init(first moment: VNVCECore.Moment.V1) {
        self.currentMoment = moment
    }
    
}
