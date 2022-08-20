//
//  TextField+Extensions.swift
//  vnvce
//
//  Created by Kerem Cesme on 12.08.2022.
//

import SwiftUI
import Introspect

extension View {
    
    public func textEditorFocusableArea() -> some View {
        
        TextEditorButton { self.contentShape(Rectangle()) }
    }
}

extension View {
    
    public func textFieldFocusableArea() -> some View {
        
        TextFieldButton { self.contentShape(Rectangle()) }
    }
}

fileprivate struct TextEditorButton<Label: View>: View {
    init(label: @escaping () -> Label) {
        self.label = label
    }
    
    var label: () -> Label
    
    private var textEditor = Weak<UITextView>(nil)
    let impactMed = UIImpactFeedbackGenerator(style: .light)
    var body: some View {
        Button(action: {
            impactMed.impactOccurred()
            self.textEditor.value?.becomeFirstResponder()
        }, label: {
            label().introspectTextView {
                self.textEditor.value = $0
            }
        }).buttonStyle(PlainButtonStyle())
    }
}

fileprivate struct TextFieldButton<Label: View>: View {
    init(label: @escaping () -> Label) {
        self.label = label
    }
    
    var label: () -> Label
    
    private var textField = Weak<UITextField>(nil)
    let impactMed = UIImpactFeedbackGenerator(style: .light)
    var body: some View {
        Button(action: {
            impactMed.impactOccurred()
            self.textField.value?.becomeFirstResponder()
        }, label: {
            label().introspectTextField {
                self.textField.value = $0
            }
        }).buttonStyle(PlainButtonStyle())
    }
}

/// Holds a weak reference to a value
public class Weak<T: AnyObject> {
    public weak var value: T?
    public init(_ value: T?) {
        self.value = value
    }
}
