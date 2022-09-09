//
//  Color+Extensions.swift
//  vnvce
//
//  Created by Kerem Cesme on 7.09.2022.
//

import Foundation
import SwiftUI
import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        let newRed = CGFloat(red)/255
        let newGreen = CGFloat(green)/255
        let newBlue = CGFloat(blue)/255
        
        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    
}

extension Color {
    enum Brightness {
        case light, medium, dark, transparent

        private enum Threshold {
            static let transparent: CGFloat = 0.1
            static let light: CGFloat = 0.75
            static let dark: CGFloat = 0.3
        }

        init(brightness: CGFloat, alpha: CGFloat) {
            if alpha < Threshold.transparent {
                self = .transparent
            } else if brightness > Threshold.light {
                self = .light
            } else if brightness < Threshold.dark {
                self = .dark
            } else {
                self = .medium
            }
        }
    }

    var brightness: Brightness {
        var b: CGFloat = 0
        var a: CGFloat = 0
        let uiColor = UIColor(self)
        uiColor.getHue(nil, saturation: nil, brightness: &b, alpha: &a)
        return .init(brightness: b, alpha: a)
    }
}

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension Color {
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat) {

        #if canImport(UIKit)
        typealias NativeColor = UIColor
        #elseif canImport(AppKit)
        typealias NativeColor = NSColor
        #endif

        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var o: CGFloat = 0

        guard NativeColor(self).getRed(&r, green: &g, blue: &b, alpha: &o) else {
            // You can handle the failure here as you want
            return (0, 0, 0, 0)
        }

        return (r, g, b, o)
    }
}

