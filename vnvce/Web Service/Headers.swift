
import Foundation
import VNVCECore
import UIKit

extension URLRequest {
    public mutating func setAcceptVersion(_ version: VNVCECore.APIVersion) {
        self.setValue(version.rawValue, forHTTPHeaderField: VNVCEHeaders.acceptVersion)
    }
    
    public mutating func setClientOS() {
        self.setValue(ClientOS.ios.rawValue, forHTTPHeaderField: VNVCEHeaders.clientOS)
    }
    
    public mutating func setClientID() throws {
        guard let clientID = UIDevice.current.identifierForVendor?.uuidString else {
            throw HeaderError.clientIdNotFound
        }
        self.setValue(clientID, forHTTPHeaderField: VNVCEHeaders.clientID)
    }
    
    public mutating func setOTPID() {
        guard let otpID = UserDefaults.standard.value(forKey: VNVCEHeaders.otpID) as? String else {
            return
        }
        self.setValue(otpID, forHTTPHeaderField: VNVCEHeaders.otpID)
    }
    
    public mutating func setOTPToken(_ token: String?) {
        if let token {
            self.setValue("Bearer \(token)", forHTTPHeaderField: VNVCEHeaders.authorization)
        }
        
    }
    
}

extension URLRequest {
    public enum HeaderError: String, Error {
        case clientIdNotFound = "Client ID not found."
    }
}

