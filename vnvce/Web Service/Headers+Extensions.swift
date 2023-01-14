
import Foundation
import VNVCECore
import UIKit
import KeychainAccess

extension URLRequest {
    public mutating func setAcceptVersion(_ version: VNVCECore.APIVersion) {
        self.setValue(version.rawValue, forHTTPHeaderField: VNVCEHeaders.acceptVersion)
    }
    
    public mutating func setClientOS() {
        self.setValue(ClientOS.ios.rawValue, forHTTPHeaderField: VNVCEHeaders.clientOS)
    }
    
    public mutating func setClientID() {
        if let clientID = UIDevice.current.identifierForVendor?.uuidString {
            self.setValue(clientID, forHTTPHeaderField: VNVCEHeaders.clientID)
        }
    }
    
    public mutating func setOTPID() {
        if let otpID = try? Keychain().get(KeychainKey.otpID) {
            self.setValue(otpID, forHTTPHeaderField: VNVCEHeaders.otpID)
        }
        
    }
    
    public mutating func setOTPToken() {
        if let token = try? Keychain().get(KeychainKey.otpToken) {
            self.setValue(token, forHTTPHeaderField: VNVCEHeaders.otpToken)
        }
    }
    
    public mutating func setAuthID() {
        if let authID = try? Keychain().get(KeychainKey.authID) {
            self.setValue(authID, forHTTPHeaderField: VNVCEHeaders.authID)
        }
    }
    
    public mutating func setUserID() {
        if let userID = try? Keychain().get(KeychainKey.userID) {
            self.setValue(userID, forHTTPHeaderField: VNVCEHeaders.userID)
        }
    }
    
    public mutating func setContentType(_ type: ContentType) {
        self.setValue(type.rawValue, forHTTPHeaderField: VNVCEHeaders.contentType)
    }
    
    public mutating func setAccessToken(authorization: Bool = true) {
        if let accessToken = try? Keychain().get(KeychainKey.accessToken) {
            if authorization {
                self.setValue("Bearer \(accessToken)", forHTTPHeaderField: VNVCEHeaders.authorization)
            } else {
                self.setValue(accessToken, forHTTPHeaderField: VNVCEHeaders.accessToken)
            }
        }
    }
    
    public mutating func setRefreshToken(authorization: Bool = true) {
        if let refreshToken = try? Keychain().get(KeychainKey.refreshToken) {
            if authorization {
                self.setValue("Bearer \(refreshToken)", forHTTPHeaderField: VNVCEHeaders.authorization)
            } else {
                self.setValue(refreshToken, forHTTPHeaderField: VNVCEHeaders.refreshToken)
            }
        }
    }
}
