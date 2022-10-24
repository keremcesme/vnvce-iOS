//
//  ColorScheme+Extension.swift
//  vnvce
//
//  Created by Kerem Cesme on 19.10.2022.
//

import SwiftUI

extension ColorScheme {
    var primaryReverse: Color {
        if self == .light {
            return Color.white
        } else {
            return Color.black
        }
    }
}
