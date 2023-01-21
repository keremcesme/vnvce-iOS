
import SwiftUI

struct UserTestModel: Identifiable {
    var id = UUID()
    let name: String
    let picture: String
    let count: Int
    let moment: String
}

class HomeViewModel: ObservableObject {
    public var scrollView: UIScrollView!
    
    public let screen: CGRect = UIScreen.main.bounds
    
    @Published var tab: String = "CAMERA"
    
    @Published private(set) public var testUsers: [UserTestModel] = [
        .init(name: "Madelyn 💧", picture: "person1", count: 3, moment: "moment1"),
        .init(name: "Phillip Mango", picture: "person2", count: 1, moment: "moment2"),
        .init(name: "Kierra Rhiel", picture: "person3", count: 2, moment: "moment3"),
        .init(name: "Tatiana", picture: "person4", count: 1, moment: "moment4"),
        .init(name: "Jacob Miller", picture: "person5", count: 2, moment: "moment5"),
        .init(name: "Joel", picture: "person6", count: 1, moment: "moment6")
    ]
    
    public func scrollViewConnector(_ scrollView: UIScrollView) {
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.setContentOffset(.init(x: screen.width, y: 0), animated: false)
        self.scrollView = scrollView
    }
    
//    public func onChangeScrollOffset(_ value: CGFloat?) {
//        if value == 0 {
//            scrollView?.isScrollEnabled = false
//        }
//    }
    
}
