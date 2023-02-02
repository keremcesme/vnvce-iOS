
import SwiftUI

struct UserTestModel: Identifiable {
    var id = UUID()
    let name: String
    let picture: String
    let count: Int
    let moment: String
}


class HomeViewModel: ObservableObject {
    public var bottomScrollView: UIScrollView!
    
    public let screen: CGRect = UIScreen.main.bounds
    public let bottomPadding: CGFloat
    
    public let navBarHeight: CGFloat = 36
    public let momentSize: CGSize
    
    public let cameraRaw = "CAMERA"
    
    @Published var tab: String
    
    @Published public var showSearchView: Bool = false
    @Published public var showProfileView: Bool = false
    
    @Published private(set) public var testUsers: [UserTestModel] = [
        .init(name: "Madelyn 💧", picture: "person1", count: 3, moment: "moment1"),
        .init(name: "Phillip Mango", picture: "person2", count: 1, moment: "moment2"),
        .init(name: "Kierra Rhiel", picture: "person3", count: 2, moment: "moment3"),
        .init(name: "Tatiana", picture: "person4", count: 1, moment: "moment4"),
        .init(name: "Jacob Miller", picture: "person5", count: 2, moment: "moment5"),
        .init(name: "Joel", picture: "person6", count: 1, moment: "moment6")
    ]
    
    init() {
        let width = screen.width
        let height = width * 3 / 2
        momentSize = CGSize(width, height)
        tab = cameraRaw
        bottomPadding = screen.width / 2 - 36
    }
    
    public func bottomScrollViewConnector(_ scrollView: UIScrollView) {
        self.bottomScrollView = scrollView
    }
    
    public func bottomScrollTo(_ inx: Int) {
        let index = CGFloat(inx + 1)
        let offset = 72 * index + 15 * index
        
        self.bottomScrollView.setContentOffset(.init(offset, 0), animated: true)
    }
    
    public func bottomResetScroll() {
        self.bottomScrollView.setContentOffset(.zero, animated: true)
    }
    
}
