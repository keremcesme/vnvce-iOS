//
//  View+Sync.swift
//  vnvce
//
//  Created by Kerem Cesme on 21.09.2022.
//

import SwiftUI

extension View {
    
    func sync<V: Equatable>(_ published: Binding<V>, with binding: Binding<V>) -> some View {
        self
            .onChange(of: published.wrappedValue) { published in
                binding.wrappedValue = published
            }
            .onChange(of: binding.wrappedValue) { binding in
                published.wrappedValue = binding
            }
    }
    
}
