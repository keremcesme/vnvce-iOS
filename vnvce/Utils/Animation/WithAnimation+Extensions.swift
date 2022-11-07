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
//        SwiftUI.withAnimation(.easeInOut(duration: response), action)
//        SwiftUI.withAnimation(.easeIn(duration: response), action)
//        SwiftUI.withAnimation(.interactiveSpring(), action)
        SwiftUI.withAnimation(.spring(response: response, dampingFraction: 0.95, blendDuration: 1), action)
        DispatchQueue.main.asyncAfter(deadline: .now() + response, execute: after)
}

func animation(response: Double, _ value: inout Bool, to: Bool) async {
    SwiftUI.withAnimation(.spring(response: response, dampingFraction: 0.95, blendDuration: 1)) {
        value = to
    }
    try? await Task.sleep(seconds: response)
}
