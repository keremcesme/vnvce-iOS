//
//  UserAPI.swift
//  vnvce
//
//  Created by Kerem Cesme on 28.09.2022.
//

import Foundation
import KeychainAccess
import Alamofire
import NIOCore

struct UserAPI {
    static let shared = UserAPI()
    
    private init() {}
    
    public let keychain = Keychain()
    public let urlBuilder = URLBuilder.shared
    public let encoder = JSONParameterEncoder.default
}

// MARK: Public Methods -
extension UserAPI {
    
    public func fetchProfile() async throws -> User.Public {
        let result = try await fetchProfileTask()
        
        switch result {
        case let .success(response):
            return response
        case let .failure(statusCode):
            if statusCode == .unauthorized {
                let response = try await TokenAPI.shared.retryTask(to: User.Public.self) {
                    switch try await fetchProfileTask() {
                    case let .success(response):
                        return response
                    case let .failure(statusCode):
                        throw generateError(code: Int(statusCode.code), description: statusCode.localizedDescription)
                    }
                }
                return response
            }
            else {
                throw generateError(code: Int(statusCode.code), description: statusCode.localizedDescription)
            }
        }
    }
    
}

// MARK: Private Methods -
extension UserAPI {
    private func fetchProfileTask() async throws -> Result<User.Public, HTTPStatus> {
        guard let token = try Keychain().get("accessToken") else {
            fatalError()
        }
     
        return .failure(HTTPStatus.unauthorized)
    }
    
    // Handle Errors
    private func generateError(code: Int = 1, description: String) -> Error {
        NSError(domain: "UserAPI", code: code, userInfo: [NSLocalizedDescriptionKey: description])
    }
}
