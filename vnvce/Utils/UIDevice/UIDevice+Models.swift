//
//  UIDevice+Models.swift
//  vnvce
//
//  Created by Kerem Cesme on 16.10.2022.
//

import Foundation
import SwiftUI

enum iPhoneModel {
    case iPhone6s
    case iPhone6sPlus
    
    case iPhone7
    case iPhone7Plus
    
    case iPhone8
    case iPhone8Plus
    
    case iPhoneX
    
    case iPhoneXS
    case iPhoneXSMax
    case iPhoneXR
    
    case iPhone11
    case iPhone11Pro
    case iPhone11ProMax
    
    case iPhone12mini
    case iPhone12
    case iPhone12Pro
    case iPhone12ProMax
    
    case iPhone13mini
    case iPhone13
    case iPhone13Pro
    case iPhone13ProMax
    
    case iPhone14
    case iPhone14Plus
    case iPhone14Pro
    case iPhone14ProMax
    
    case iPhoneSE
    case iPhoneSE2nd
    case iPhoneSE3nd
    
    case notAvailableiPhone
}

extension UIDevice {
    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity

            switch identifier {
                case "iPhone3,1", "iPhone3,2", "iPhone3,3":           return "iPhone 4"
                case "iPhone4,1":                                     return "iPhone 4s"
                
                case "iPhone5,1", "iPhone5,2":                        return "iPhone 5"
                case "iPhone5,3", "iPhone5,4":                        return "iPhone 5c"
                case "iPhone6,1", "iPhone6,2":                        return "iPhone 5s"
                
                case "iPhone7,2":                                     return "iPhone 6"
                case "iPhone7,1":                                     return "iPhone 6 Plus"
                case "iPhone8,1":                                     return "iPhone 6s"
                case "iPhone8,2":                                     return "iPhone 6s Plus"
                
                case "iPhone9,1", "iPhone9,3":                        return "iPhone 7"
                case "iPhone9,2", "iPhone9,4":                        return "iPhone 7 Plus"
                
                case "iPhone10,1", "iPhone10,4":                      return "iPhone 8"
                case "iPhone10,2", "iPhone10,5":                      return "iPhone 8 Plus"
                
                case "iPhone10,3", "iPhone10,6":                      return "iPhone X"
                
                case "iPhone11,2":                                    return "iPhone XS"
                case "iPhone11,4", "iPhone11,6":                      return "iPhone XS Max"
                case "iPhone11,8":                                    return "iPhone XR"
                
                case "iPhone12,1":                                    return "iPhone 11"
                case "iPhone12,3":                                    return "iPhone 11 Pro"
                case "iPhone12,5":                                    return "iPhone 11 Pro Max"
                
                case "iPhone13,1":                                    return "iPhone 12 mini"
                case "iPhone13,2":                                    return "iPhone 12"
                case "iPhone13,3":                                    return "iPhone 12 Pro"
                case "iPhone13,4":                                    return "iPhone 12 Pro Max"
                
                case "iPhone14,4":                                    return "iPhone 13 mini"
                case "iPhone14,5":                                    return "iPhone 13"
                case "iPhone14,2":                                    return "iPhone 13 Pro"
                case "iPhone14,3":                                    return "iPhone 13 Pro Max"
                
                case "iPhone14,7":                                    return "iPhone 14"
                case "iPhone14,8":                                    return "iPhone 14 Plus"
                case "iPhone15,2":                                    return "iPhone 14 Pro"
                case "iPhone15,3":                                    return "iPhone 14 Pro Max"
                
                case "iPhone8,4":                                     return "iPhone SE"
                case "iPhone12,8":                                    return "iPhone SE (2nd generation)"
                case "iPhone14,6":                                    return "iPhone SE (3rd generation)"
                case "i386", "x86_64", "arm64":                       return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
                default:                                              return identifier
            }
        }
        
        return mapToDevice(identifier: identifier)
    }()
    
}

extension String {
    
    func deviceModel() -> iPhoneModel {
        
        let modelName = self
        
        switch modelName {
        case "iPhone 6s":                     return .iPhone6s
        case "iPhone 6s Plus":                return .iPhone6sPlus
            
        case "iPhone 7":                      return .iPhone7
        case "iPhone 7 Plus":                 return .iPhone7Plus
            
        case "iPhone 8":                      return .iPhone8
        case "iPhone 8 Plus":                 return .iPhone8Plus
            
        case "iPhone X":                      return .iPhoneX
            
        case "iPhone XS":                     return .iPhoneXS
        case "iPhone XS Max":                 return .iPhoneXSMax
        case "iPhone XR":                     return .iPhoneXR
            
        case "iPhone 11":                     return .iPhone11
        case "iPhone 11 Pro":                 return .iPhone11Pro
        case "iPhone 11 Pro Max":             return .iPhone11ProMax
            
        case "iPhone 12 mini":                return .iPhone12mini
        case "iPhone 12":                     return .iPhone12
        case "iPhone 12 Pro":                 return .iPhone12Pro
        case "iPhone 12 Pro Max":             return .iPhone12ProMax
            
        case "iPhone 13 mini":                return .iPhone13mini
        case "iPhone 13":                     return .iPhone13
        case "iPhone 13 Pro":                 return .iPhone13Pro
        case "iPhone 13 Pro Max":             return .iPhone13ProMax
        
        case "iPhone 14":                     return .iPhone14
        case "iPhone 14 Plus":                return .iPhone14Plus
        case "iPhone 14 Pro":                 return .iPhone14Pro
        case "iPhone 14 Pro Max":             return .iPhone14ProMax
            
            
        case "iPhone SE":                     return .iPhoneSE
        case "iPhone SE (2nd generation)":    return .iPhoneSE2nd
        case "iPhone SE (3nd generation)":    return .iPhoneSE3nd
            
        default:                              return .notAvailableiPhone
            
        }
        
        
    }
    
    
}


