//
//  CustomAnimations.swift
//  vnvce
//
//  Created by Kerem Cesme on 19.09.2022.
//

import Foundation
import SwiftUI

extension Animation {
    static var post: Animation {
        Animation.spring(response: 0.25, dampingFraction: 1, blendDuration: 0)
    }
}
