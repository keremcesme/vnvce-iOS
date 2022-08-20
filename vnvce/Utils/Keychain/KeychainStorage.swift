//
//  KeychainStorage.swift
//  vnvce
//
//  Created by Kerem Cesme on 10.08.2022.
//

import KeychainAccess
import SwiftUI

@propertyWrapper
struct KeychainStorage: DynamicProperty {
    let key: String
    
    @State private var value: String
    
    init(wrappedValue: String = "", _ key: String) {
        self.key = key
        let initialValue = (try? Keychain().get(key)) ?? wrappedValue
        self._value = State<String>(initialValue: initialValue)
    }
    
    var wrappedValue: String {
        get  { value }
        
        nonmutating set {
            value = newValue
            do {
                try Keychain().set(value, key: key)
            } catch let error {
                fatalError("\(error)")
            }
        }
    }
    var projectedValue: Binding<String> {
        Binding(get: { wrappedValue }, set: { wrappedValue = $0 })
    }
}
