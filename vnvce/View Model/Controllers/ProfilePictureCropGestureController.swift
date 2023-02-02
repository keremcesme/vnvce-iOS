
import SwiftUI

class ProfilePictureCropGestureController: NSObject, ObservableObject {
    
    @Published public var offset: CGSize = .zero
    
    public func addPanGesture() -> UIGestureRecognizer {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGesture))
        panGesture.delegate = self
        
        return panGesture
    }
    
    public func addPanGesture2() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGesture))
        panGesture.delegate = self
        let root = findRootViewController()
        panGesture.name = "KEREM GESTURE"
        root.view.addGestureRecognizer(panGesture)
        print(root.view.gestureRecognizers?.contains(where: {$0.name == "KEREM GESTURE"}))
        print("burasi 22222")
    }
    
    // MARK: Finding Root Controller
    private func findRootViewController() -> UIViewController {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = screen.windows.first?.rootViewController
        else {
            return .init()
        }
        
        return root
    }
}

extension ProfilePictureCropGestureController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    
    @objc
    private func panGesture(_ gesture: UIPanGestureRecognizer) {
        print("burasi")
        
        let translation = gesture.translation(in: gesture.view)
        let velo = gesture.velocity(in: gesture.view)
        
        let x: CGFloat = translation.width
        let y: CGFloat = translation.height
        
        print("burasi")
        
        self.offset = .init(x, y)
    }
}
