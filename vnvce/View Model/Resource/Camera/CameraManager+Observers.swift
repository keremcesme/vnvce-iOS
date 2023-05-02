//
//  CameraManager+Observers.swift
//  vnvce
//
//  Created by Kerem Cesme on 16.10.2022.
//

import AVFoundation

extension CameraManager {
    // MARK: Notification Observer Handling
    public func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionRuntimeErrorOccurred(notification:)),
                                               name: NSNotification.Name.AVCaptureSessionRuntimeError,
                                               object: session)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionWasInterrupted(notification:)),
                                               name: NSNotification.Name.AVCaptureSessionWasInterrupted,
                                               object: session)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionInterruptionEnded),
                                               name: NSNotification.Name.AVCaptureSessionInterruptionEnded,
                                               object: session)
    }
    
    public func removeObservers() {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.AVCaptureSessionRuntimeError,
                                                  object: session)
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.AVCaptureSessionWasInterrupted,
                                                  object: session)
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.AVCaptureSessionInterruptionEnded,
                                                  object: session)
    }
    
    // MARK: Notification Observers
    @objc func sessionWasInterrupted(notification: Notification) {
        
        if let userInfoValue = notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as AnyObject?,
           let reasonIntegerValue = userInfoValue.integerValue,
           let reason = AVCaptureSession.InterruptionReason(rawValue: reasonIntegerValue) {
            print("Capture session was interrupted with reason \(reason)")
            
            var canResumeManually = false
            if reason == .videoDeviceInUseByAnotherClient {
                canResumeManually = true
            } else if reason == .videoDeviceNotAvailableWithMultipleForegroundApps {
                canResumeManually = false
            }
            
            self.delegate?.sessionWasInterrupted(canResumeManually: canResumeManually)
            
        }
    }
    
    @objc func sessionInterruptionEnded(notification: Notification) {
        
        self.delegate?.sessionInterruptionEnded()
    }
    
    @objc func sessionRuntimeErrorOccurred(notification: Notification) {
        guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else {
            return
        }
        
        print("Capture session runtime error: \(error.localizedDescription)")
        
        if error.code == .mediaServicesWereReset {
            sessionQueue.async {
                if self.sessionIsRunning {
                    self.startSession()
                } else {
                    DispatchQueue.main.async {
                        self.delegate?.sessionRunTimeErrorOccurred()
                    }
                }
            }
        } else {
            self.delegate?.sessionRunTimeErrorOccurred()
            
        }
    }
}
