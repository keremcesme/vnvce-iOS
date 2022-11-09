//
//  AsyncTapGesture.swift
//  vnvce
//
//  Created by Kerem Cesme on 8.11.2022.
//

import SwiftUI

struct AsyncTapGestureModifier: ViewModifier {
    private var count: Int
    private var action: @Sendable () async -> ()
    
    init(count: Int,
         action: @Sendable @escaping () async -> ()
    ) {
        self.count = count
        self.action = action
    }
    
    private func task() {
        Task(operation: action)
    }
    
    func body(content: Content) -> some View {
        content
            .onTapGesture(count: count, perform: task)
    }
}

extension View {
    func onTapGesture(
        count: Int = 1,
        perform: @Sendable @escaping () async -> ()
    ) -> some View {
        modifier(AsyncTapGestureModifier(count: count, action: perform))
    }
}
