//
//  HideKeyboard.swift
//  vnvce
//
//  Created by Kerem Cesme on 12.08.2022.
//

import SwiftUI
import UIKit

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
    }
}
#endif
