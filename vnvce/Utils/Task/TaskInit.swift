//
//  TaskInit.swift
//  vnvce
//
//  Created by Kerem Cesme on 19.08.2022.
//

import Foundation
import SwiftUI

/// You can check the initliaze status from the `initalized` variable.
/// Even if you do not enter the `Binding` parameter,
/// the method will be called once.
///
/// - Parameters:
///   - isInitliazed: The `Binding<Bool>` value that
///   indicates the init status.
///   - priority: Priority value for `async` methods only.
///     - Default: `TaskPriority.userInitiated`
///   - action: Async or normal method.

// - MARK: USAGE EXAMPLE -
struct ContentViewTEST: View {
    
    @State var initalized: Bool = false
    
    var body: some View {
        Text("Hello World!")
///         Methods to be called once when the view appears.
///         - Async
            .taskInit(asyncInit)
///         - Async With `initalized` Parameter
            .taskInit($initalized, asyncInit)
///         - Normal
            .taskInit(normalInit)
///         - Normal With `initalized` Parameter
            .taskInit($initalized, normalInit)
    }
    
    @Sendable
    func asyncInit() async {
        // ...
    }
    @Sendable
    func normalInit() {
        // ...
    }
}

// - MARK: SOURCE CODE -
typealias AsyncFunction = @Sendable () async -> Void
typealias Function =  () -> Void

enum FunctionType {
    case async(AsyncFunction)
    case normal(Function)
    case empty
}

protocol InitTaskProtocol {
    func asyncTask(_ action: AsyncFunction) async
    func task(_ action: Function)
    func returnFunction() -> FunctionType
}

struct InitTaskModifier: ViewModifier, InitTaskProtocol {

    @Binding var isInitialized: Bool
    
    let priority: TaskPriority
    let asyncAction: AsyncFunction?
    let action: Function?
    
    func body(content: Content) -> some View {
        content
            .background(Background)
    }
    
    @ViewBuilder
    private var Background: some View {
        if !isInitialized {
            switch returnFunction() {
                case .async(let action):
                    if #available(iOS 15.0, *) {
                        Color.clear
                            .task(priority: priority) { await asyncTask(action) }
                    } else {
                        Color.clear
                            .onAppear {
                                Task {
                                    await asyncTask(action)
                                }
                            }
                    }
                case .normal(let action):
                    Color.clear
                        .onAppear{ task(action) }
                case .empty:
                    EmptyView()
            }
        }
    }
    
    internal func asyncTask(_ action: AsyncFunction) async {
        await action()
        isInitialized = true
    }
    
    internal func task(_ action: Function) {
        action()
        isInitialized = true
    }
    
    internal func returnFunction() -> FunctionType {
        if let asyncAction = asyncAction {
            return .async(asyncAction)
        } else if let action = action {
            return .normal(action)
        } else {
            return .empty
        }
    }
}

struct InitTaskAutoModifier: ViewModifier, InitTaskProtocol {

    @State var isInitialized: Bool = false
    
    let priority: TaskPriority
    let asyncAction: AsyncFunction?
    let action: Function?
    
    func body(content: Content) -> some View {
        content
            .background(Background)
    }
    
    @ViewBuilder
    private var Background: some View {
        if !isInitialized {
            switch returnFunction() {
                case .async(let action):
                    if #available(iOS 15.0, *) {
                        Color.clear
                            .task(priority: priority) { await asyncTask(action) }
                    } else {
                        Color.clear
                            .onAppear {
                                Task {
                                    await asyncTask(action)
                                }
                            }
                    }
                case .normal(let action):
                    Color.clear
                        .onAppear{ task(action) }
                case .empty:
                    EmptyView()
            }
        }
    }
    
    internal func asyncTask(_ action: AsyncFunction) async {
        await action()
        isInitialized = true
    }
    
    internal func task(_ action: Function) {
        action()
        isInitialized = true
    }
    
    internal func returnFunction() -> FunctionType {
        if let asyncAction = asyncAction {
            return .async(asyncAction)
        } else if let action = action {
            return .normal(action)
        } else {
            return .empty
        }
    }
}

extension View {
    
    func taskInit(
        _ isInitialized: Binding<Bool>,
        priority: TaskPriority = .userInitiated,
        _ action: @escaping AsyncFunction
    ) -> some View {
        modifier(
            InitTaskModifier(
                isInitialized: isInitialized,
                priority: priority,
                asyncAction: action,
                action: nil
            )
        )
    }
    
    func taskInit(
        _ isInitialized: Binding<Bool>,
        _ action: @escaping Function
    ) -> some View {
        modifier(
            InitTaskModifier(
                isInitialized: isInitialized,
                priority: .userInitiated,
                asyncAction: nil,
                action: action
            )
        )
    }
    
    func taskInit(
        priority: TaskPriority = .userInitiated,
        _ action: @escaping AsyncFunction
    ) -> some View {
        modifier(
            InitTaskAutoModifier(
                priority: priority,
                asyncAction: action,
                action: nil
            )
        )
    }
    
    func taskInit(
        _ action: @escaping Function
    ) -> some View {
        modifier(
            InitTaskAutoModifier(
                priority: .userInitiated,
                asyncAction: nil,
                action: action
            )
        )
    }
}


