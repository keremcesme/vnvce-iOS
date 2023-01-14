//
//  MeAPIOLD.swift
//  vnvce
//
//  Created by Kerem Cesme on 22.08.2022.
//

import Foundation
import KeychainAccess
import Alamofire
import NIOCore

struct MeAPIOLD {
    static let shared = MeAPIOLD()
    
    private init() {}
    
    public let keychain = Keychain()
    public let urlBuilder = URLBuilder.shared
    public let encoder = JSONParameterEncoder.default
}

// MARK: Public Methods -
extension MeAPIOLD {
    public func fetchProfile() async throws -> User? {
        let result = try await fetchProfileTask()
        
        switch result {
            case let .success(user):
                return user
            case let .failure(statusCode):
                if statusCode == .unauthorized {
                    var userResult: User?
                    try await TokenAPI.shared.generateTokens {
                        let result = try await fetchProfileTask()
                        switch result {
                            case let .success(user):
                                userResult = user
                            case let .failure(statusCode):
                                throw generateError(code: Int(statusCode.code), description: statusCode.localizedDescription)
                        }
                    }
                    
                    return userResult
                    
                } else {
                    throw generateError(code: Int(statusCode.code), description: statusCode.localizedDescription)
                }
                
        }
    }
}

// MARK: Private Methods -
extension MeAPIOLD {
    
    private func fetchProfileTask() async throws -> Result<User, HTTPStatus>{
        guard let token = try Keychain().get("accessToken") else {
            fatalError()
        }
        
        let route: MeRoute = .profile
        let url = urlBuilder.meURL(route: route, version: .v1)
        
        var headers = HTTPHeaders()
        headers.add(.authorization(bearerToken: token))
        
        let task = AF
            .request(url, method: .get, headers: headers)
            .serializingDecodable(Response<User>.self)
        
        let response = await task.response
        
        guard let statusCode = response.response?.statusCode else {
            throw NSError(domain: "Status Code not Available", code: 1)
        }
        
        switch response.result {
            case let .success(user):
                return .success(user.result!)
            case .failure(_):
                return .failure(HTTPStatus(statusCode: statusCode))
        }
    }
   
    // Handle Errors
    private func generateError(code: Int = 1, description: String) -> Error {
        NSError(domain: "MeAPI", code: code, userInfo: [NSLocalizedDescriptionKey: description])
    }
}
