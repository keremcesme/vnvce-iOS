//
//  WithAnimation+Extensions.swift
//  vnvce
//
//  Created by Kerem Cesme on 19.09.2022.
//

import Foundation
import SwiftUI

func withAnimation(
    response: Double,
    _ action: @escaping () -> Void,
    after: @escaping () -> Void) {
        SwiftUI.withAnimation(.spring(response: response, dampingFraction: 1, blendDuration: 0), action)
        DispatchQueue.main.asyncAfter(deadline: .now() + response, execute: after)
}

