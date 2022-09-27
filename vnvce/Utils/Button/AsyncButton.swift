//
//  AsyncButton.swift
//  vnvce
//
//  Created by Kerem Cesme on 27.09.2022.
//

import SwiftUI

struct AsyncButton<Label: View>: View {
    
    let role: ButtonRole?
    var priority: TaskPriority?
    var action: @Sendable () async -> Void
    
    @ViewBuilder var label: () -> Label
    
    init(role: ButtonRole? = .none,
         priority: TaskPriority? = .none,
         action: @Sendable @escaping () async -> Void,
         @ViewBuilder label: @escaping () -> Label) {
        self.role = role
        self.action = action
        self.label = label
    }
    
    private func task() {
        Task(priority: priority, operation: action)
    }
    
    var body: some View {
        SwiftUI.Button(role: role, action: task, label: label)
    }
}
