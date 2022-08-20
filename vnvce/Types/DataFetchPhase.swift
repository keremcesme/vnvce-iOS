//
//  DataFetchPhase.swift
//  vnvce
//
//  Created by Kerem Cesme on 19.08.2022.
//

import Foundation

enum DataFetchPhase<T> {
    
    case empty
    case success(T)
    case fetchingNextPage(T)
    case failure(Error)
    
    var value: T? {
        if case let .success(value) = self {
            return value
        } else if case let .fetchingNextPage(value) = self {
            return value
        }
        return nil
    }
    
}
