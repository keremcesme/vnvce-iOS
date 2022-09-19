//
//  CustomTransitions.swift
//  vnvce
//
//  Created by Kerem Cesme on 19.09.2022.
//

import Foundation
import SwiftUI

extension AnyTransition {
    static func position(_ offset: CGSize) -> AnyTransition {
        
        let zeroX: CGFloat = UIScreen.main.bounds.width / 2
        let zeroY: CGFloat = UIScreen.main.bounds.height / 2
        
        let width: CGFloat = -zeroX + offset.x
        let height: CGFloat = -zeroY + offset.y
        
        let offset: CGSize = CGSize(width, height)
        
        return AnyTransition.offset(offset)
    }
}
