//
//  ViewControllerHoldefr.swift
//  vnvce
//
//  Created by Kerem Cesme on 10.11.2022.
//

import UIKit
import SwiftUI

struct ViewControllerHolder {
    weak var value: UIViewController?
    init(_ value: UIViewController?) {
        self.value = value
    }
}

struct ViewControllerKey: EnvironmentKey {
    static var defaultValue: ViewControllerHolder { return ViewControllerHolder(UIApplication.shared.firstKeyWindow?.rootViewController ) }
}

extension EnvironmentValues {
    var viewController: ViewControllerHolder {
        get { return self[ViewControllerKey.self] }
        set { self[ViewControllerKey.self] = newValue }
    }
}

extension UIViewController {
    
    func present<Content: View>(
        presentationStyle: UIModalPresentationStyle = .overFullScreen,
        transitionStyle: UIModalTransitionStyle = .coverVertical,
        animated: Bool = true,
        backgroundColor: UIColor = .clear,
        completion: @escaping () -> Void = {},
        @ViewBuilder content: () -> Content
    ) {
        let toPresent = UIHostingController(rootView: AnyView(EmptyView()))
        toPresent.modalPresentationStyle = presentationStyle
        toPresent.modalTransitionStyle = transitionStyle
        toPresent.rootView = AnyView(
            content()
                .environment(\.viewController, ViewControllerHolder(toPresent))
        )
        
        
        toPresent.view.backgroundColor = backgroundColor // This line is modified
        self.present(toPresent, animated: animated, completion: completion)
        self.isModalInPresentation = true
    }
    
}
