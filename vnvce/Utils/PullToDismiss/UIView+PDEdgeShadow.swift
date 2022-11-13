//
//  UIView+PDEdgeShadow.swift
//  vnvce
//
//  Created by Kerem Cesme on 10.11.2022.
//

import Foundation
import UIKit

extension UIView {
    func applyEdgeShadow(_ shadow: PDEdgeShadow?) {
        guard let shadow = shadow else {
            detachEdgeShadow()
            return
        }
        layer.shadowOpacity = shadow.opacity
        layer.shadowRadius = shadow.radius
        layer.shadowOffset = shadow.offset
        layer.shadowColor = shadow.color.cgColor
//        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        
    }
    
    func updateEdgeShadow(_ shadow: PDEdgeShadow?, rate: CGFloat) {
        guard let shadow = shadow else {
            detachEdgeShadow()
            return
        }
        layer.shadowOpacity = shadow.opacity * Float(rate)
    }
    
    func detachEdgeShadow() {
        layer.shadowOpacity = 0.0
        layer.shadowRadius = 0
        layer.shadowOffset = .zero
        layer.shadowColor = nil
        layer.shadowPath = nil
    }
}
