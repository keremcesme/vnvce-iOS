//
//  YPPagerMenu.swift
//  vnvce
//
//  Created by Kerem Cesme on 11.09.2022.
//

import UIKit
import Stevia

final class YPPagerMenu: UIView {
    
    var didSetConstraints = false
    var menuItems = [YPMenuItem]()
    
    convenience init() {
        self.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        clipsToBounds = true
    }
    
    var separators = [UIView]()
    
    func setUpMenuItemsConstraints() {
        let screenWidth = YPImagePickerConfiguration.screenWidth
        let menuItemWidth: CGFloat = screenWidth / CGFloat(menuItems.count)
        var previousMenuItem: YPMenuItem?
        for m in menuItems {
            subviews(
                m
            )
            
            m.fillVertically().width(menuItemWidth)
            if let pm = previousMenuItem {
                pm-0-m
            } else {
                |m
            }
            
            previousMenuItem = m
        }
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        if !didSetConstraints {
            setUpMenuItemsConstraints()
        }
        didSetConstraints = true
    }
    
    func refreshMenuItems() {
        didSetConstraints = false
        updateConstraints()
    }
}
