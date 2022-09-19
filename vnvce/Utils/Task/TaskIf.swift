//
//  TaskIf.swift
//  vnvce
//
//  Created by Kerem Cesme on 19.09.2022.
//

import Foundation
import SwiftUI

struct TaskIfModifier: ViewModifier {
    let condition: Bool
    let priority: TaskPriority
    let action: @Sendable () async -> Void
    
    func body(content: Content) -> some View {
        content
            .background {
                if condition {
                    Color.clear
                        .task(priority: priority, action)
                }
            }
    }
}

struct TaskIfModifierID<T: Equatable>: ViewModifier {
    let condition: Bool
    let id: T
    let priority: TaskPriority
    let action: @Sendable () async -> Void
    
    func body(content: Content) -> some View {
        content
            .background {
                if condition {
                    Color.clear
                        .task(id: id, priority: priority, action)
                }
            }
    }
}



extension View {
    func task(
        if condition: Bool,
        priority: TaskPriority = .userInitiated,
        _ action: @escaping @Sendable () async -> Void
    ) -> some View {
        modifier(
            TaskIfModifier(
                condition: condition,
                priority: priority,
                action: action)
        )
    }
    
    func task<T>(
        if condition: Bool,
        id value: T,
        priority: TaskPriority = .userInitiated,
        _ action: @escaping @Sendable () async -> Void
    ) -> some View where T : Equatable {
        modifier(TaskIfModifierID(
            condition: condition,
            id: value,
            priority: priority,
            action: action))
    }
    
    
}
