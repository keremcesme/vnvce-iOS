//
//  NavigationBar+Extensions.swift
//  vnvce
//
//  Created by Kerem Cesme on 12.08.2022.
//

import SwiftUI

// - MARK: Navigation Bar -
extension UINavigationBar {
    static func changeAppearance(clear: Bool) {
        let appearance = UINavigationBarAppearance()
        
        if clear {
            appearance.configureWithTransparentBackground()
        } else {
            appearance.configureWithDefaultBackground()
        }
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}


fileprivate struct HideBackAndInlineDisplay: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
    }
}

fileprivate struct ToolbarModifier<Item: ToolbarContent>: ViewModifier {
    let items: Item
    func body(content: Content) -> some View {
        content.toolbar { items }
    }
}

fileprivate struct HideBackAndInlineDisplayToolbar<Item: ToolbarContent>: ViewModifier {
    let items: Item
    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { items }
    }
}

extension View {
    public func hideBackButtonInline(
    ) -> some View {
        modifier(HideBackAndInlineDisplay())
    }
    
    public func toolbar<Item: ToolbarContent>(
        _ items: Item
    ) -> some View {
        modifier(ToolbarModifier(items: items))
    }
    
    public func hideBackButtonInlineToolbar<Item: ToolbarContent>(
        _ items: Item
    ) -> some View {
        modifier(HideBackAndInlineDisplayToolbar(items: items))
    }
}
