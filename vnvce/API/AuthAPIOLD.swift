//
//  AuthAPIOLD.swift
//  vnvce
//
//  Created by Kerem Cesme on 18.08.2022.
//

import Foundation
import KeychainAccess
import Alamofire
import NIOCore

struct AuthAPIOLD {
    static let shared = AuthAPIOLD()
    
    private init() {}
    
    private let urlBuilder = URLBuilder.shared
    
    private let encoder = JSONParameterEncoder.default
}

// MARK: Create Account Methods -
extension AuthAPIOLD {
    
    // Step 1 - Check phone number availability.
    public func checkPhoneNumber(phoneNumber: String, clientID: String) async throws -> PhoneNumberAvailability? {
        let route: AuthRoute = .create(.phone(.check(phoneNumber, clientID)))
        let url = urlBuilder.authURL(route: route, version: .v1)
        
        var headers = Alamofire.HTTPHeaders()
        headers.add(.contentType("application/json"))
        
        let task = AF
            .request(
                url,
                method: .get,
                headers: headers)
            .serializingDecodable(Response<PhoneNumberAvailability>.self)
        
        
        let result = await task.result
        
        switch result {
            case let .success(response):
                return response.result
            case let .failure(error):
                throw error
        }
    }
    
    // Auto - Check username availabiltiy.
    public func autoCheckUsername(username: String, clientID: String) async throws -> UsernameAvailabilityOLD? {
        let route: AuthRoute = .create(.username(.check(username, clientID)))
        let url = urlBuilder.authURL(route: route, version: .v1)
        
        var headers = Alamofire.HTTPHeaders()
        headers.add(.contentType("application/json"))
        
        let task = AF
            .request(
                url,
                method: .get,
                headers: headers)
            .serializingDecodable(Response<UsernameAvailabilityOLD>.self)
        
        
        let result = await task.result
        
        switch result {
            case let .success(response):
                return response.result
            case let .failure(error):
                throw error
        }
    }
    
    // Step 2 - Reserve Username and Send OTP code to phone number.
    public func reserveUsernameAndSendSMSOTP(payload: ReserveUsernameAndSendSMSOTPPayload) async throws -> ReserveUsernameAndSendSMSOTPResponse? {
        let route: AuthRoute = .create(.reserveUsernameAndSendOTP)
        let url = urlBuilder.authURL(route: route, version: .v1)
        
        var headers = Alamofire.HTTPHeaders()
        headers.add(.contentType("application/json"))
        
        let task = AF.request(
            url,
            method: .post,
            parameters: payload,
            encoder: encoder,
            headers: headers)
            .serializingDecodable(Response<ReserveUsernameAndSendSMSOTPResponse>.self)
        
        
        let result = await task.result
        
        switch result {
            case let .success(response):
                return response.result
            case let .failure(error):
                throw error
        }
    }
    
    // Resend SMS OTP
    public func resendSMSOTP(payload: SendSMSOTPPayload) async throws -> SMSOTPAttempt? {
        let route: AuthRoute = .create(.phone(.resendOTP))
        let url = urlBuilder.authURL(route: route, version: .v1)
        
        var headers = Alamofire.HTTPHeaders()
        headers.add(.contentType("application/json"))
        
        let task = AF.request(
            url,
            method: .post,
            parameters: payload,
            encoder: encoder,
            headers: headers)
            .serializingDecodable(Response<SMSOTPAttempt>.self)
        
        
        let result = await task.result
        
        switch result {
            case let .success(response):
                return response.result
            case let .failure(error):
                throw error
        }
    }
    
    // Step 3 - Verify OTP and create account.
    public func createAccount(payload: CreateAccountPayload) async throws -> CreateAccountResponse? {
        let route: AuthRoute = .create(.newAccount)
        let url = urlBuilder.authURL(route: route, version: .v1)
        
        var headers = Alamofire.HTTPHeaders()
        headers.add(.contentType("application/json"))
        
        let task = AF.request(
            url,
            method: .post,
            parameters: payload,
            encoder: encoder,
            headers: headers)
            .serializingDecodable(Response<CreateAccountResponse>.self)
        
        let result = await task.result
        
        switch result {
            case let .success(response):
                return response.result
            case let .failure(error):
                throw error
        }
    }
    
}

// MARK: Private Methods -
private extension AuthAPIOLD {
    // Handle Errors
    private func generateError(code: Int = 1, description: String) -> Error {
        NSError(domain: "AuthAPI", code: code, userInfo: [NSLocalizedDescriptionKey: description])
    }
}
