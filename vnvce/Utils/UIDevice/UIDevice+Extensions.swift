//
//  UIDevice+Extensions.swift
//  vnvce
//
//  Created by Kerem Cesme on 7.09.2022.
//

import Foundation
import SwiftUI

extension UIDevice {
    
    func hasNotch() -> Bool {
        if #available(iOS 15.0, *) {
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            let bottom = windowScene?.keyWindow?.safeAreaInsets.bottom ?? 0
            return bottom > 0
        } else {
            let window = UIApplication.shared.keyWindow
            let bottom = window?.safeAreaInsets.bottom ?? 0
            return bottom > 0
        }
    }
    
    func statusBarHeight() -> CGFloat {
        
        if #available(iOS 15.0, *) {
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            let top = windowScene?.keyWindow?.safeAreaInsets.top ?? 0
            return top
        } else {
            let window = UIApplication.shared.keyWindow
            let top = window?.safeAreaInsets.top ?? 0
            return top
        }
    }
    
    func bottomSafeAreaHeight() -> CGFloat {
        if #available(iOS 15.0, *) {
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            let bottom = windowScene?.keyWindow?.safeAreaInsets.bottom ?? 0
            return bottom
        } else {
            let window = UIApplication.shared.keyWindow
            let bottom = window?.safeAreaInsets.bottom ?? 0
            return bottom
        }
    }
    
    func tabBarHeight() -> CGFloat {
        let bottom: CGFloat = {
            if #available(iOS 15.0, *) {
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                return windowScene?.keyWindow?.safeAreaInsets.bottom ?? 0
            } else {
                let window = UIApplication.shared.keyWindow
                return window?.safeAreaInsets.bottom ?? 0
            }
        }()
        
        let tabBarHeight = 55.0
        let verticalPadding = 15.0
        
        return bottom + tabBarHeight + verticalPadding * 2
        
    }
    
    func hideStatusBar() {
        UIApplication.shared.isStatusBarHidden = true
    }
    
    func showStatusBar() {
        UIApplication.shared.isStatusBarHidden = false
    }
    
    func setStatusBar(style: UIStatusBarStyle, animation: Bool) {
        UIApplication.shared.setStatusBarStyle(style, animated: animation)
    }
    
    func statusBarVisibility(hide: Bool, animation: UIStatusBarAnimation = .fade) {
        UIApplication.shared.setStatusBarHidden(hide, with: animation)
    }
    
    func cameraSize() -> CGSize {
        switch hasNotch() {
            case true:
                let ratio = 1.777777777777778
                let width = UIScreen.main.bounds.width
                return CGSize(width: width, height: width * ratio)
            case false:
                return UIScreen.main.bounds.size
        }
    }
    
    func screenCornerRadius() -> CGFloat {
        let window = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let radius = (window?.screen.displayCornerRadius ?? 0) - 1.5
        return radius
    }
    
}
