//
//  PDScrollViewDelegateProxy.swift
//  vnvce
//
//  Created by Kerem Cesme on 10.11.2022.
//

import Foundation
import UIKit

class PDScrollViewDelegateProxy: PDDelegateProxy, UIScrollViewDelegate {
    @nonobjc convenience init(delegates: [UIScrollViewDelegate]) {
        self.init(__delegates: delegates)
    }
}
