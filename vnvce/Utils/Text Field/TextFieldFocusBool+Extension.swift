//
//  TextFieldFocusBool+Extension.swift
//  vnvce
//
//  Created by Kerem Cesme on 18.08.2022.
//

import Foundation
import Focuser

extension Bool: FocusStateCompliant {
    public static var last: Bool {
        true
    }
    
    public var next: Bool? {
        switch self {
            case true: return true
            case false: return nil
        }
    }
}
