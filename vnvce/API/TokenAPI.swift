//
//  TokenAPI.swift
//  vnvce
//
//  Created by Kerem Cesme on 22.08.2022.
//

import Foundation
import Alamofire
import KeychainAccess
import UIKit

fileprivate enum GenerateTokensResult {
    case ok
    case logout
}

struct TokenAPI {
    static let shared = TokenAPI()
    
    private init() {}
    
    private let keychain = Keychain()
    private let urlBuilder = URLBuilder.shared
    private let encoder = JSONParameterEncoder.default
    private let userDefaults = UserDefaults.standard
}

// MARK: Public Methods -
extension TokenAPI {
    
    public func retryTask<T: Decodable>(
        to: T.Type, task: @escaping () async throws -> T
    ) async throws -> T {
        try await generateTokens()
        return try await task()
    }
    
    public func generateTokens(task: @escaping () async throws -> ()) async throws {
        switch try await generateTokensTask() {
            case .ok:
                try await task()
            case .logout:
                DispatchQueue.main.async {
                    userDefaults.set(false, forKey: "loggedIn")
                }
        }
    }
    
    public func generateTokens() async throws {
        switch try await generateTokensTask() {
            case .ok:
                return
            case .logout:
                DispatchQueue.main.async {
                    userDefaults.set(false, forKey: "loggedIn")
                }
        }
    }
    
}


// MARK: Private Methods -
extension TokenAPI {
    private func generateTokensTask() async throws -> GenerateTokensResult {
        guard let userIdString = userDefaults.value(forKey: "currentUserID") as? String,
              let userID = UUID(uuidString: userIdString),
              let refreshToken = try keychain.get("refreshToken"),
              let clientID = await UIDevice.current.identifierForVendor
        else {
            return .logout
        }
        
        let url = urlBuilder.tokenURL(route: .generate, version: .v1)
        
        let payload = GenerateTokensPayload(userID: userID, refreshToken: refreshToken, clientID: clientID)
        
        var headers = HTTPHeaders()
        headers.add(.contentType(MIMEType.appJSON))
        
        let task = AF.request(
            url,
            method: .post,
            parameters: payload,
            encoder: encoder,
            headers: headers)
            .serializingDecodable(Response<TokenResponse>.self)
        
        let result = await task.result
        
        switch result {
            case let .success(response):
                guard let result = response.result else {
                    fatalError()
                }
                switch result {
                    case let .success(tokens):
                        if let accessToken = tokens.accessToken {
                            keychain["accessToken"] = accessToken
                        }
                        if let refreshToken = tokens.refreshToken {
                            keychain["refreshToken"] = refreshToken
                        }
                        return .ok
                    case let .failure(error):
                        print(error.rawValue)
                        try keychain.remove("accessToken")
                        try keychain.remove("refreshToken")
                        userDefaults.removeObject(forKey: "currentUserID")
                        return .logout
                }
            case let .failure(error):
                throw generateError(description: error.localizedDescription)
        }
    }
}

// MARK: Private Methods -
private extension TokenAPI {
    // Handle Errors
    private func generateError(code: Int = 1, description: String) -> Error {
        NSError(domain: "TokenAPI", code: code, userInfo: [NSLocalizedDescriptionKey: description])
    }
}
