//
//  CameraManagerDelegate.swift
//  vnvce
//
//  Created by Kerem Cesme on 16.10.2022.
//

import SwiftUI
import AVFoundation
import UIKit

protocol CameraManagerDelegate: AnyObject {
    
    /**
     This method delivers the pixel buffer of the current frame seen by the device's camera.
     */
    func didOutput(pixelBuffer: CVPixelBuffer)
    
    /**
     This method intimates that the camera permissions have been denied.
     */
    func presentCameraPermissionsDeniedAlert()
    
    /**
     This method intimates that there was an error in video configuration.
     */
    func presentVideoConfigurationErrorAlert()
    
    /**
     This method intimates that a session runtime error occurred.
     */
    func sessionRunTimeErrorOccurred()
    
    /**
     This method intimates that the session was interrupted.
     */
    func sessionWasInterrupted(canResumeManually resumeManually: Bool)
    
    /**
     This method intimates that the session interruption has ended.
     */
    func sessionInterruptionEnded()
    
}
