//
//  Introspect+Extensions.swift
//  vnvce
//
//  Created by Kerem Cesme on 14.11.2022.
//

import SwiftUI
import Introspect

extension View {
    func introspectView(customize: @escaping (UIView) -> Void) -> some View {
        
        return inject(
            UIKitIntrospectionView(
                selector: { introspectionView in
                    guard let viewHost = Introspect.findViewHost(from: introspectionView) else {
                        return nil
                    }
                    return Introspect.previousSibling(containing: UIView.self, from: viewHost)
                },
                customize: customize)
        )
        
    }
}

extension View {
    func addGestureRecognizer(_ gesture: UIGestureRecognizer) -> some View {
        self
            .introspectView(customize: { $0.addGestureRecognizer(gesture) })
    }
}
