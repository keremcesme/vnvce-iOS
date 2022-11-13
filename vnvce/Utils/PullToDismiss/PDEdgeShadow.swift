//
//  PDEdgeShadow.swift
//  vnvce
//
//  Created by Kerem Cesme on 10.11.2022.
//

import Foundation
import UIKit

public final class PDEdgeShadow: NSObject {
    @objc(defaultEdgeShadow)
    public static let `default` = PDEdgeShadow(
        opacity: 0.5, radius: 5.0, color: .black, offset: CGSize(width: 0.0, height: -5.0)
    )
    
    public let opacity: Float
    public let radius: CGFloat
    public let color: UIColor
    public let offset: CGSize
    
    public init(opacity: Float, radius: CGFloat, color: UIColor, offset: CGSize) {
        self.opacity = opacity
        self.radius = radius
        self.color = color
        self.offset = offset
        super.init()
    }
    
    // only Objective-C
    @available(*, unavailable)
    public class func edgeShadow(opacity: Float, radius: CGFloat, color: UIColor, offset: CGSize) -> PDEdgeShadow {
        return PDEdgeShadow.init(opacity: opacity, radius: radius, color: color, offset: offset)
    }
}
