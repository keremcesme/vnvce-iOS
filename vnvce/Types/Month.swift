//
//  Month.swift
//  vnvce
//
//  Created by Kerem Cesme on 24.10.2022.
//

import Foundation

enum Month: String, Codable {
    case january, february, march, april, may, june, july, august, september, october, november, december
    
    static let schema = "month"
}

extension Month {
    var convertToInt: Int {
        switch self {
        case .january:
            return 1
        case .february:
            return 2
        case .march:
            return 3
        case .april:
            return 4
        case .may:
            return 5
        case .june:
            return 6
        case .july:
            return 7
        case .august:
            return 8
        case .september:
            return 9
        case .october:
            return 10
        case .november:
            return 11
        case .december:
            return 12
        }
    }
}

extension Int {
    func convertToMonth() throws -> Month {
        switch self {
        case 1:
            return .january
        case 2:
            return .february
        case 3:
            return .march
        case 4:
            return .april
        case 5:
            return .may
        case 6:
            return .june
        case 7:
            return .july
        case 8:
            return .august
        case 9:
            return .september
        case 10:
            return .october
        case 11:
            return .november
        case 12:
            return .december
        default:
            throw NSError(domain: "Invalid month.", code: self)
        }
    }
}
