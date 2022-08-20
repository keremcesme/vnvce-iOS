//
//  OTPViewModel.swift
//  vnvce
//
//  Created by Kerem Cesme on 12.08.2022.
//

import SwiftUI
import Focuser

// MARK: FocusState enum
enum OTPField {
    case field1
    case field2
    case field3
    case field4
    case field5
    case field6
}

extension OTPField: FocusStateCompliant {
    static var last: OTPField {
        .field6
    }
    
    var next: OTPField? {
        switch self {
            case .field1:
                return .field2
            case .field2:
                return .field3
            case .field3:
                return .field4
            case .field4:
                return .field5
            case .field5:
                return .field6
            default: return nil
                
        }
    }
}

class OTPViewModel: ObservableObject {
    @Published public var otpText: String = ""
    @Published public var otpFields: [String] = Array(repeating: "", count: 6)
//    @Published public var activeField: OTPField?
}
