//
//  AuthAPI.swift
//  vnvce
//
//  Created by Kerem Cesme on 18.08.2022.
//

import Foundation
import KeychainAccess

struct AuthAPI {
    static let shared = AuthAPI()
    
    private init() {}
    
    private let session = URLSession.shared
    
    private let urlBuilder = URLBuilder.shared
    private let urlRequestBuilder = URLRequestBuilder.shared
    private let request = Request.shared
}

// MARK: Create Account Methods -
extension AuthAPI {
    
    // Step 1 - Check phone number availability.
    public func checkPhoneNumber(phoneNumber: String, clientID: String) async throws -> Response<CheckPhoneNumberResponse> {
        let route: AuthRoute = .create(.phone(.check(phoneNumber, clientID)))
        let url = urlBuilder.authURL(route: route, version: .v1)
        let result = try await url.get(decode: Response<CheckPhoneNumberResponse>.self)
        
        if result.response.code == .ok || result.response.code == .notFound {
            return result.response
        } else {
            let code = result.httpResponse.httpResponse.statusCode == 401 ? 401 : 1
            throw generateError(code: code,  description: result.response.message)
        }
    }
    
    // Auto - Check username availabiltiy.
    public func autoCheckUsername(username: String, clientID: String) async throws -> Response<AutoCheckUsernameResponse> {
        let route: AuthRoute = .create(.username(.check(username, clientID)))
        let url = urlBuilder.authURL(route: route, version: .v1)
        let result = try await url.get(decode: Response<AutoCheckUsernameResponse>.self)
        
        if result.response.code == .ok || result.response.code == .notFound {
            return result.response
        } else {
            let code = result.httpResponse.httpResponse.statusCode == 401 ? 401 : 1
            throw generateError(code: code,  description: result.response.message)
        }
    }
    
    // Step 2 - Reserve Username and Send OTP code to phone number.
    public func reserveUsernameAndSendSMSOTP(payload: ReserveUsernameAndSendSMSOTPPayload) async throws -> Response<ReserveUsernameAndSendSMSOTPResponse> {
        let route: AuthRoute = .create(.reserveUsernameAndSendOTP)
        let url = urlBuilder.authURL(route: route, version: .v1)
        let data = try payload.encode()
        let result = try await url.post(data: data, authorization: false, decode: Response<ReserveUsernameAndSendSMSOTPResponse>.self)
        
        if result.response.code == .ok || result.response.code == .notFound {
            return result.response
        } else {
            let code = result.httpResponse.httpResponse.statusCode == 401 ? 401 : 1
            throw generateError(code: code,  description: result.response.message)
        }
    }
    
    // Resend SMS OTP
    public func resendSMSOTP(payload: ResendSMSOTPPayload) async throws -> Response<ResendSMSOTPResponse> {
        let route: AuthRoute = .create(.phone(.resendOTP))
        let url = urlBuilder.authURL(route: route, version: .v1)
        let data = try payload.encode()
        let result = try await url.post(data: data, authorization: false, decode: Response<ResendSMSOTPResponse>.self)
        
        if result.response.code == .ok || result.response.code == .notFound {
            return result.response
        } else {
            let code = result.httpResponse.httpResponse.statusCode == 401 ? 401 : 1
            throw generateError(code: code,  description: result.response.message)
        }
    }
    
    // Step 3 - Verify OTP and create account.
    public func createAccount(payload: CreateAccountPayload) async throws -> Response<CreateAccountResponse> {
        let route: AuthRoute = .create(.newAccount)
        let url = urlBuilder.authURL(route: route, version: .v1)
        let payload = try payload.encode()
        let result = try await url.post(data: payload, authorization: false, decode: Response<CreateAccountResponse>.self)
        
        if result.response.code == .ok || result.response.code == .notFound {
            return result.response
        } else {
            let code = result.httpResponse.httpResponse.statusCode == 401 ? 401 : 1
            throw generateError(code: code,  description: result.response.message)
        }
    }
    
}

// MARK: Private Methods -
private extension AuthAPI {
    // Handle Errors
    private func generateError(code: Int = 1, description: String) -> Error {
        NSError(domain: "AuthAPI", code: code, userInfo: [NSLocalizedDescriptionKey: description])
    }
}
