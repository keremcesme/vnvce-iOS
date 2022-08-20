//
//  Dismiss+Extension.swift
//  vnvce
//
//  Created by Kerem Cesme on 12.08.2022.
//

import SwiftUI

@available(iOS 14.0, *)
extension EnvironmentValues {
    var dismiss: () -> Void {
        {
            presentationMode.wrappedValue.dismiss()
        }
    }
}
