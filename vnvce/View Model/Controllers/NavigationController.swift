//
//  NavigationController.swift
//  vnvce
//
//  Created by Kerem Cesme on 12.08.2022.
//

import SwiftUI
import UIKit

class NavigationController: ObservableObject {
    
    @Published public var navigation = NavigationCoordinator()
    
    public func properties(_ controller: UINavigationController) {
        navigation.controller = controller
        controller.setNavigationBarHidden(true, animated: false)
        controller.delegate = navigation
        controller.interactivePopGestureRecognizer?.delegate = navigation
        controller.interactivePopGestureRecognizer?.isEnabled = true
    }
}


class NavigationCoordinator: NSObject, UIGestureRecognizerDelegate, UINavigationControllerDelegate {
    var controller: UINavigationController!
    
    var enabled = true
    
    public func gestureRecognizerShouldBegin(
        _ gestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        if enabled {
            return controller.viewControllers.count > 1
        } else {
            return false
        }
    }
    
    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        false
    }
}
