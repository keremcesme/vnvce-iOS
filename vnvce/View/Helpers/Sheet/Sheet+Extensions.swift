
import SwiftUI

struct CustomSheet: ViewModifier {
    @Environment(\.viewController) public var viewControllerHolder: ViewControllerHolder
    
    func body(content: Content) -> some View {
        Button(action: show, label: content)
    }
    
    private func show() {
        guard let controller = self.viewControllerHolder.value else {
            return
        }
        
        
    }
}

