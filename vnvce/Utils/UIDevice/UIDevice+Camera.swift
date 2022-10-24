//
//  UIDevice+Camera.swift
//  vnvce
//
//  Created by Kerem Cesme on 16.10.2022.
//

import Foundation
import AVFoundation

enum TelephotoSupportedDevicess {
    case iPhone7Plus
    case iPhone8Plus
    case iPhoneX
    case iPhoneXS
    case iPhoneXSMax
    case iPhone11Pro
    case iPhone11ProMax
    case iPhone12Pro
    case iPhone12ProMax
    case iPhone13Pro
    case iPhone13ProMax
}



let UltraWideSupportedDevices: [iPhoneModel] = [
    .iPhone11,
    .iPhone11Pro,
    .iPhone11ProMax,
    .iPhone12,
    .iPhone12mini,
    .iPhone12Pro,
    .iPhone12ProMax,
    .iPhone13mini,
    .iPhone13,
    .iPhone13Pro,
    .iPhone13ProMax,
    .iPhone14,
    .iPhone14Plus,
    .iPhone14Pro,
    .iPhone14ProMax
]

let UltraWideSelfieSupportedDevices: [iPhoneModel] = [
    .iPhone11,
    .iPhone11Pro,
    .iPhone11ProMax,
    .iPhone12,
    .iPhone12mini,
    .iPhone12Pro,
    .iPhone12ProMax,
    .iPhone13mini,
    .iPhone13,
    .iPhone13Pro,
    .iPhone13ProMax,
    .iPhone14,
    .iPhone14Plus,
    .iPhone14Pro,
    .iPhone14ProMax
]

let TelephotoSupportedDevices: [iPhoneModel] = [
    .iPhone7Plus,
    .iPhone8Plus,
    .iPhoneX,
    .iPhoneXS,
    .iPhoneXSMax,
    .iPhone11Pro,
    .iPhone11ProMax,
    .iPhone12Pro,
    .iPhone12ProMax,
    .iPhone13Pro,
    .iPhone13ProMax,
    .iPhone14Pro,
    .iPhone14ProMax
]

let TrueDepthSupportedDevices: [iPhoneModel] = [
    .iPhoneX,
    .iPhoneXS,
    .iPhoneXSMax,
    .iPhoneXR,
    .iPhone11,
    .iPhone11Pro,
    .iPhone11ProMax,
    .iPhone12mini,
    .iPhone12,
    .iPhone12Pro,
    .iPhone12ProMax,
    .iPhone13mini,
    .iPhone13,
    .iPhone13Pro,
    .iPhone13ProMax,
    .iPhone14,
    .iPhone14Plus,
    .iPhone14Pro,
    .iPhone14ProMax
]

enum TelephotoMode {
    case single(CGFloat)
    case double(CGFloat, CGFloat)
}

enum CameraType {
    case triple
    case wideAndTelephoto
    case wideAndUltraWide
    case wide
}

typealias CaptureDeviceType = (device: AVCaptureDevice.DeviceType, type: CameraType)

extension iPhoneModel {
    
    func setTelephoto() -> TelephotoMode? {
        switch self {
        case .iPhone7Plus, .iPhone8Plus, .iPhoneX, .iPhoneXS, .iPhoneXSMax, .iPhone11Pro, .iPhone11ProMax, .iPhone12Pro:
            return .single(2.0)
        case .iPhone12ProMax:
            return .single(2.5)
        case .iPhone13Pro, .iPhone13ProMax:
            return .single(3.0)
        case .iPhone14Pro, .iPhone14ProMax:
            return .double(2.0, 3.0)
        default:
            return nil
        }
    }
    
    func setUltraWide() -> Bool {
        for device in UltraWideSupportedDevices where self == device {
            return true
        }
        
        return false
    }
    
//    func setCaptureDeviceType() -> CaptureDeviceType {
//        switch self {
//        case .iPhone11Pro, .iPhone11ProMax, .iPhone12Pro, .iPhone12ProMax, .iPhone13Pro, .iPhone13ProMax, .iPhone14Pro, .iPhone14ProMax:
//            return (.builtInTripleCamera, .triple)
//        case .iPhone11, .iPhone12mini, .iPhone12, .iPhone13mini, .iPhone13, .iPhone14, .iPhone14Plus:
//            return (.builtInDualWideCamera, .wideAndUltraWide)
//        case .iPhone7Plus, .iPhone8Plus, .iPhoneX, .iPhoneXS, .iPhoneXSMax:
//            return (.builtInDualCamera, .wideAndTelephoto)
//        default:
//            return (.builtInWideAngleCamera, .wide)
//        }
//    }
    
    func setCaptureDevice() -> AVCaptureDevice.DeviceType {
        switch self {
        case .iPhone11Pro, .iPhone11ProMax, .iPhone12Pro, .iPhone12ProMax, .iPhone13Pro, .iPhone13ProMax, .iPhone14Pro, .iPhone14ProMax:
            return .builtInTripleCamera
        case .iPhone11, .iPhone12mini, .iPhone12, .iPhone13mini, .iPhone13, .iPhone14, .iPhone14Plus:
            return .builtInDualWideCamera
        case .iPhone7Plus, .iPhone8Plus, .iPhoneX, .iPhoneXS, .iPhoneXSMax:
            return .builtInDualCamera
        default:
            return .builtInWideAngleCamera
        }
    }
    
    func setCameraType() -> CameraType {
        switch self {
        case .iPhone11Pro, .iPhone11ProMax, .iPhone12Pro, .iPhone12ProMax, .iPhone13Pro, .iPhone13ProMax, .iPhone14Pro, .iPhone14ProMax:
            return .triple
        case .iPhone11, .iPhone12mini, .iPhone12, .iPhone13mini, .iPhone13, .iPhone14, .iPhone14Plus:
            return .wideAndUltraWide
        case .iPhone7Plus, .iPhone8Plus, .iPhoneX, .iPhoneXS, .iPhoneXSMax:
            return .wideAndTelephoto
        default:
            return .wide
        }
    }
    
    func setFrontCaptureDevice() -> AVCaptureDevice.DeviceType {
        for device in TrueDepthSupportedDevices where self == device {
            return .builtInTrueDepthCamera
        }
        return .builtInWideAngleCamera
    }
    
    var telephotoZoomFactor: String? {
        switch self {
        case .iPhone7Plus, .iPhone8Plus, .iPhone11Pro, .iPhone11ProMax, .iPhone12Pro, .iPhone14Pro, .iPhone14ProMax:
            return "2"
        case .iPhone12ProMax:
            return "2.5"
        case .iPhone13Pro, .iPhone13ProMax:
            return "3"
        default :
            return nil
        }
    }
    
    var secondTelephotoZoomFactor: String? {
        switch self {
        case .iPhone14Pro, .iPhone14ProMax:
            return "3"
        default :
            return nil
        }
    }
}
