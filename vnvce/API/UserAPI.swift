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
    
    public func fetchProfile(userID: String) async throws -> User.Public {
        let result = try await fetchProfileTask(userID)
        
        switch result {
        case let .success(response):
            return response
        case let .failure(statusCode):
            if statusCode == .unauthorized {
                let response = try await TokenAPI.shared.retryTask(to: User.Public.self) {
                    switch try await fetchProfileTask(userID) {
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
    private func fetchProfileTask(_ userID: String) async throws -> Result<User.Public, HTTPStatus> {
        guard let token = try Keychain().get("accessToken") else {
            fatalError()
        }
        
        var url = urlBuilder.userURL(route: .profile(userID: userID), version: .v1)
        var headers = HTTPHeaders()
        headers.add(.authorization(bearerToken: token))
        
        let task = AF
            .request(
                url,
                method: .post,
                headers: headers)
            .serializingDecodable(Response<User.Public>.self)
        
        let taskResponse = await task.response
        
        guard let statusCode = taskResponse.response?.statusCode else {
            throw NSError(domain: "Status Code not Available", code: 1)
        }
        
        switch taskResponse.result {
            case let .success(response):
                guard let result = response.result else {
                    throw NSError(domain: "Result is not available", code: 1)
                }
                return .success(result)
            case .failure(_):
                return .failure(HTTPStatus(statusCode: statusCode))
        }
    }
    
    // Handle Errors
    private func generateError(code: Int = 1, description: String) -> Error {
        NSError(domain: "UserAPI", code: code, userInfo: [NSLocalizedDescriptionKey: description])
    }
}
