
import Foundation
import Alamofire
import KeychainAccess
import VNVCECore
import UIKit
import NIO

actor AuthAPI {
    
    private let session = URLSession.shared
    private let api = VNVCECore.AuthAPI.V1.shared
    private let endpoint = Endpoint.shared
    
    func checkPhoneNumber(_ phoneNumber: String) async throws -> RequestResponse.V1 {
        let params: [URLQueryItem] = [
            .init(name: "phone_number", value: phoneNumber)
        ]
        
        let url = endpoint.makeURL(api.checkPhoneNumber, params: params, host: WebConstants.url)
        
        var request = URLRequest(url: url)
        request.httpMethod = VNVCECore.HTTPMethod.post.rawValue
        request.setAcceptVersion(.v1)
        request.setClientOS()
        request.setOTPID()
        try request.setClientID()
        
        let (data, rsp) = try await session.data(for: request)
        
        guard let response = rsp as? HTTPURLResponse,
              HTTPStatus(statusCode: response.statusCode) == .ok
        else {
            return .init(error: true, message: "Unknown error.")
        }
        
        let result = try JSONDecoder().decode(RequestResponse.V1.self, from: data)
        
        return result
    }
    
    func checkUsername(_ username: String) async throws -> RequestResponse.V1 {
        let params: [URLQueryItem] = [
            .init(name: "username", value: username)
        ]
        
        let url = endpoint.makeURL(api.checkUsername, params: params, host: WebConstants.url)
        
        
        var request = URLRequest(url: url)
        request.httpMethod = VNVCECore.HTTPMethod.post.rawValue
        request.setAcceptVersion(.v1)
        request.setClientOS()
        
        try request.setClientID()
        
        let (data, rsp) = try await session.data(for: request)
        
        guard let response = rsp as? HTTPURLResponse,
              HTTPStatus(statusCode: response.statusCode) == .ok
        else {
            return .init(error: true, message: "Unknown error.")
        }
        
        let result = try JSONDecoder().decode(RequestResponse.V1.self, from: data)
        
        return result
    }
    
    func reserveUsernameAndSendOTP(phone number: String, username: String, otpToken: String? = nil) async throws -> OTPResponse.V1 {
        let params: [URLQueryItem] = [
            .init(name: "phone_number", value: number),
            .init(name: "username", value: username)
        ]
        
        let url = endpoint.makeURL(api.reserveUsernameSendOTP, params: params, host: WebConstants.url)
        
        var request = URLRequest(url: url)
        request.httpMethod = VNVCECore.HTTPMethod.post.rawValue
        request.setAcceptVersion(.v1)
        request.setClientOS()
        request.setOTPID()
        request.setOTPToken(otpToken)
        try request.setClientID()
        
        let (data, rsp) = try await session.data(for: request)
        
        guard let response = rsp as? HTTPURLResponse,
              HTTPStatus(statusCode: response.statusCode) == .ok
        else {
            throw NSError(domain: "Unknown error", code: 1)
        }
        
        let result = try JSONDecoder().decode(OTPResponse.V1.self, from: data)
        
        return result
    }
}
