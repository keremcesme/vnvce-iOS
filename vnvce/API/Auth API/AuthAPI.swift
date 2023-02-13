
import Foundation
import KeychainAccess
import VNVCECore
import NIO
import UIKit

actor AuthAPI {
    
    private let session = URLSession.shared
    private let userDefaults = UserDefaults.standard
    private let routes = AuthRoutes.V1.shared
    private var endpoint = Endpoint.shared
    private let keychain = Keychain()
    private let pkce = PKCEService()
    
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder: JSONDecoder = JSONDecoder()
    
    public init() {
        endpoint.run = WebConstants.run
    }
}

// Access Resource
extension AuthAPI {
    
    func secureTask(
        _ request: URLRequest
    ) async throws -> Data? {
        var _request = request
        _request.setAccessToken()
        _request.setAuthID()
        _request.setClientID()
        _request.setClientOS()
        
        let (data, rsp) = try await session.data(for: _request)
        
        guard let response = rsp as? HTTPURLResponse else {
            fatalError()
        }
        
        let status = HTTPStatus(statusCode: response.statusCode)
        
        switch status {
        case .ok:
            return data
        case .unauthorized:
            switch try await generateAccessToken() {
            case .ok:
                return try await secureTask(request)
            case .unauthorized:
                switch try await reauthorize() {
                case .ok:
                    return try await secureTask(request)
                default:
                    try await forceLogout()
                    return nil
                }
            default:
                try await forceLogout()
                return nil
            }
        default:
            try await forceLogout()
            return nil
        }
    }
    
    func secureTask<T>(
        _ request: URLRequest,
        decode to: T.Type
    ) async throws -> T? where T: Decodable {
        var _request = request
        _request.setAccessToken()
        _request.setAuthID()
        _request.setClientID()
        _request.setClientOS()
        
        let (data, rsp) = try await session.data(for: _request)
        
        guard let response = rsp as? HTTPURLResponse else {
            fatalError()
        }
        
        let status = HTTPStatus(statusCode: response.statusCode)
        
        switch status {
        case .ok:
            let result = try jsonDecoder.decode(to, from: data)
            return result
        case .unauthorized:
            switch try await generateAccessToken() {
            case .ok:
                return try await secureTask(request, decode: to)
            case .unauthorized:
                switch try await reauthorize() {
                case .ok:
                    return try await secureTask(request, decode: to)
                default:
                    try await forceLogout()
                    return nil
                }
            default:
                try await forceLogout()
                return nil
            }
        default:
            try await forceLogout()
            print("Unknown Status Code: \(status.code)")
            return nil
        }
    }
    
    private func forceLogout() async throws {
        await MainActor.run {
            userDefaults.set(false, forKey: UserDefaultsKey.loggedIn)
            userDefaults.set(false, forKey: UserDefaultsKey.accountIsCreated)
        }
        
        try keychain.removeAll()
    }
}

// Token
extension AuthAPI {
    func authorize() async throws {
        let codeVerifier = await pkce.generateCodeVerifier()
        let codeChallenge = try await pkce.generateCodeChallenge(fromVerifier: codeVerifier)
        
        let params: [URLQueryItem] = [
            .init(name: "code_challenge", value: codeChallenge)
        ]
        
        let url = endpoint.makeURL(routes.authorize, params: params, api: .auth)
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post
        request.setAcceptVersion(.v1)
        request.setClientOS()
        request.setClientID()
        request.setUserID()
        
        let (data, rsp) = try await session.data(for: request)
        
        guard let response = rsp as? HTTPURLResponse,
              HTTPStatus(statusCode: response.statusCode) == .ok
        else {
            return
        }
        
        let authResponse = try jsonDecoder.decode(AuthorizeResponse.V1.self, from: data)
        
        let authCode = authResponse.authCode
        let authID = authResponse.authID
        
        try keychain.set(codeVerifier, key: KeychainKey.codeVerifier)
        try keychain.set(codeChallenge, key: KeychainKey.codeChallenge)
        try keychain.set(authCode, key: KeychainKey.authCode)
        try keychain.set(authID, key: KeychainKey.authID)
    }
    
    func generateTokens(_ payload: VNVCECore.GenerateTokensPayload.V1) async throws {
        let url = endpoint.makeURL(routes.generateTokens, api: .auth)
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post
        request.setAcceptVersion(.v1)
        request.setClientOS()
        request.setClientID()
        request.setAuthID()
        
        let body = try jsonEncoder.encode(payload)
        request.httpBody = body
        request.setContentType(.json)
        
        let (data, rsp) = try await session.data(for: request)
        
        guard let response = rsp as? HTTPURLResponse else {
            throw NSError(domain: "Unknown error", code: 1)
        }
        
        let status = HTTPStatus(statusCode: response.statusCode)
        
        switch status {
        case .ok:
            let tokens = try JSONDecoder().decode(TokensResponse.V1.self, from: data)
            try keychain.set(tokens.refreshToken, key: KeychainKey.refreshToken)
            try keychain.set(tokens.accessToken, key: KeychainKey.accessToken)
        default:
            try await forceLogout()
            return
        }
    }
    
    func generateAccessToken() async throws -> HTTPStatus {
        let url = endpoint.makeURL(routes.generateAccessToken, api: .auth)
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post
        request.setAcceptVersion(.v1)
        request.setClientOS()
        request.setClientID()
        request.setRefreshToken()
        request.setAccessToken(authorization: false)
        
        let (data, rsp) = try await session.data(for: request)
        
        guard let response = rsp as? HTTPURLResponse else {
            fatalError()
        }
        
        let status = HTTPStatus(statusCode: response.statusCode)
        
        if status == .ok {
            let accessToken = try jsonDecoder.decode(AccessTokenResponse.V1.self, from: data).token
            try keychain.set(accessToken, key: KeychainKey.accessToken)
        }
        
        return status
    }
    
    func reauthorize() async throws -> HTTPStatus {
        guard let oldAuthCode = try keychain.get(KeychainKey.authCode),
              let oldCodeVerifier = try keychain.get(KeychainKey.codeVerifier)
        else {
            fatalError()
        }
        
        let newCodeVerifier = await pkce.generateCodeVerifier()
        let newCodeChallenge = try await pkce.generateCodeChallenge(fromVerifier: newCodeVerifier)
        
        let params: [URLQueryItem] = [
            .init(name: "code_challenge", value: newCodeChallenge)
        ]
        
        let url = endpoint.makeURL(routes.reauthorize, params: params, api: .auth)
        
        let payload = ReAuthorizePayload.V1(authCode: oldAuthCode, codeVerifier: oldCodeVerifier)
        let body = try jsonEncoder.encode(payload)
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post
        request.setAcceptVersion(.v1)
        request.setClientOS()
        request.setClientID()
        request.setAuthID()
        request.setUserID()
        request.setRefreshToken(authorization: false)
        request.setContentType(.json)
        request.httpBody = body
        
        let (data, rsp) = try await session.data(for: request)
        
        guard let response = rsp as? HTTPURLResponse else {
            fatalError()
        }
        
        let status = HTTPStatus(statusCode: response.statusCode)
        
        if status == .ok {
            let authResponse = try jsonDecoder.decode(AuthorizeResponse.V1.self, from: data)
            
            let authCode = authResponse.authCode
            let authID = authResponse.authID
            
            try keychain.set(newCodeVerifier, key: KeychainKey.codeVerifier)
            try keychain.set(newCodeChallenge, key: KeychainKey.codeChallenge)
            try keychain.set(authCode, key: KeychainKey.authCode)
            try keychain.set(authID, key: KeychainKey.authID)
            
            let tokensPayload = VNVCECore.GenerateTokensPayload.V1(
                authCode: authCode,
                codeVerifier: newCodeVerifier)
            
            try await generateTokens(tokensPayload)
        }
        
        return status
    }
}

// Create Account
extension AuthAPI {
    func checkPhoneNumber(_ phoneNumber: String) async throws -> RequestResponse.V1 {
        let params: [URLQueryItem] = [
            .init(name: "phone_number", value: phoneNumber)
        ]
        
        let url = endpoint.makeURL(routes.checkPhoneNumber, params: params, api: .auth)
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post
        request.setAcceptVersion(.v1)
        request.setClientOS()
        request.setOTPID()
        request.setClientID()
        
        let (data, rsp) = try await session.data(for: request)
        
        guard let response = rsp as? HTTPURLResponse,
              HTTPStatus(statusCode: response.statusCode) == .ok
        else {
            return .init(error: true, message: "Unknown error.")
        }
        
        let result = try jsonDecoder.decode(RequestResponse.V1.self, from: data)
        
        return result
    }
    
    func checkUsername(_ username: String) async throws -> RequestResponse.V1 {
        let params: [URLQueryItem] = [
            .init(name: "username", value: username)
        ]
        
        let url = endpoint.makeURL(routes.checkUsername, params: params, api: .auth)
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post
        request.setAcceptVersion(.v1)
        request.setClientOS()
        request.setClientID()
        
        let (data, rsp) = try await session.data(for: request)
        
        guard let response = rsp as? HTTPURLResponse,
              HTTPStatus(statusCode: response.statusCode) == .ok
        else {
            return .init(error: true, message: "Unknown error.")
        }
        
        let result = try jsonDecoder.decode(RequestResponse.V1.self, from: data)
        
        return result
    }
    
    func reserveUsernameAndSendOTP(phone number: String, username: String) async throws -> OTPResponse.V1 {
        
        let params: [URLQueryItem] = [
            .init(name: "phone_number", value: number),
            .init(name: "username", value: username)
        ]
        
        let url = endpoint.makeURL(routes.reserveUsernameSendOTP, params: params, api: .auth)
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post
        request.setAcceptVersion(.v1)
        request.setClientOS()
        request.setClientID()
        request.setOTPID()
        request.setOTPToken()
        
        let (data, rsp) = try await session.data(for: request)
        
        guard let response = rsp as? HTTPURLResponse,
              HTTPStatus(statusCode: response.statusCode) == .ok
        else {
            throw NSError(domain: "Unknown error", code: 1)
        }
        
//        let str = String(decoding: data, as: UTF8.self)
        
        let result = try JSONDecoder().decode(OTPResponse.V1.self, from: data)
        return result
    }
    
    func createAccount(_ payload: VNVCECore.CreateAccountPayload.V1) async throws -> VNVCECore.CreateAccountResponse.V1{
        
        let url = endpoint.makeURL(routes.createAccount, api: .auth)
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post
        request.setAcceptVersion(.v1)
        request.setClientOS()
        request.setClientID()
        request.setOTPToken()
        
        let body = try jsonEncoder.encode(payload)
        request.httpBody = body
        request.setContentType(.json)
        
        let (data, rsp) = try await session.data(for: request)
        
        guard let response = rsp as? HTTPURLResponse,
              HTTPStatus(statusCode: response.statusCode) == .ok
        else {
            throw NSError(domain: "Unknown error", code: 1)
        }
        
        let result = try jsonDecoder.decode(VNVCECore.CreateAccountResponse.V1.self, from: data)
        
        return result
    }
}

// Login
extension AuthAPI {
    func checkPhoneAndSendOTP(_ phoneNumber: String) async throws -> AuthorizeAndOTPResponse.V1 {
        let codeVerifier = await pkce.generateCodeVerifier()
        let codeChallenge = try await pkce.generateCodeChallenge(fromVerifier: codeVerifier)
        
        let params: [URLQueryItem] = [
            .init(name: "phone_number", value: phoneNumber),
            .init(name: "code_challenge", value: codeChallenge)
        ]
        
        let url = endpoint.makeURL(routes.checkPhoneNumberSendOTP, params: params, api: .auth)
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post
        request.setAcceptVersion(.v1)
        request.setClientOS()
        request.setClientID()
        request.setOTPToken()
        request.setOTPID()
        
        let (data, rsp) = try await session.data(for: request)
        
        guard let response = rsp as? HTTPURLResponse else {
            fatalError()
        }
        
        let status = HTTPStatus(statusCode: response.statusCode)
        
        if status == .ok {
            let result = try jsonDecoder.decode(AuthorizeAndOTPResponse.V1.self, from: data)
            try keychain.removeAll()
            
            try keychain.set(codeVerifier, key: KeychainKey.codeVerifier)
            try keychain.set(codeChallenge, key: KeychainKey.codeChallenge)
            try keychain.set(result.authorize.authCode, key: KeychainKey.authCode)
            try keychain.set(result.authorize.authID, key: KeychainKey.authID)
            try keychain.set(result.otp.otp.token, key: KeychainKey.otpToken)
            try keychain.set(result.otp.otp.id, key: KeychainKey.otpID)
            
            return result
        } else {
            throw status
        }
    }
    
    func verifyOTPAndLogin(_ phoneNumber: String, code: String) async throws {
        
        let params: [URLQueryItem] = [
            .init(name: "phone_number", value: phoneNumber),
            .init(name: "code", value: code)
        ]
        
        let url = endpoint.makeURL(routes.verifyOTPGenerateTokens, params: params, api: .auth)
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post
        request.setAcceptVersion(.v1)
        request.setClientOS()
        request.setClientID()
        request.setAuthID()
        request.setOTPID()
        request.setOTPToken()
        
        guard let authCode = try keychain.get(KeychainKey.authCode),
              let codeVerifier = try keychain.get(KeychainKey.codeVerifier) else {
            throw NSError(domain: "", code: 1)
        }
        
        let payload = VerifyOTPAndLoginPayload.V1(authCode: authCode, codeVerifier: codeVerifier)
        let body = try jsonEncoder.encode(payload)
        request.httpBody = body
        request.setContentType(.json)
        
        let (data, rsp) = try await session.data(for: request)
        
        guard let response = rsp as? HTTPURLResponse else {
            fatalError()
        }
        
        let status = HTTPStatus(statusCode: response.statusCode)
        
        if status == .ok {
            let result = try jsonDecoder.decode(LoginResponse.V1.self, from: data)
            try keychain.set(result.userID, key: KeychainKey.userID)
            try keychain.set(result.tokens.accessToken, key: KeychainKey.accessToken)
            try keychain.set(result.tokens.refreshToken, key: KeychainKey.refreshToken)
            try keychain.remove(KeychainKey.otpToken)
            try keychain.remove(KeychainKey.otpID)
        } else {
            throw status
        }
    }
}

// Logout
extension AuthAPI {
    func logout() async  {
        let url = endpoint.makeURL(routes.logout, api: .auth)
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get
        request.setAcceptVersion(.v1)
        request.setAuthID()
        request.setUserID()
        
        _ = try? await session.data(for: request)
        
        try? keychain.removeAll()
        
        await MainActor.run {
            UIDevice.current.setStatusBar(style: .default, animation: true)
        }
    }
}
