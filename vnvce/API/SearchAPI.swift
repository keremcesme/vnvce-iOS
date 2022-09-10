//
//  SearchAPI.swift
//  vnvce
//
//  Created by Kerem Cesme on 10.09.2022.
//

import Foundation
import KeychainAccess
import Alamofire
import NIOCore

struct SearchAPI {
    static let shared = SearchAPI()
    
    private init() {}
    
    public let keychain = Keychain()
    public let urlBuilder = URLBuilder.shared
    public let encoder = JSONParameterEncoder.default
}

// MARK: Public Methods -
extension SearchAPI {
    public func searchUser(_ searchTerm: String, page: Int, per: Int) async throws -> PaginationResult<User.Public>? {
        let result = try await searchUserTask(searchTerm, page: page, per: per)
        
        switch result {
            case let .success(response):
                return (response.users, response.metadata)
            case let .failure(statusCode):
                if statusCode == .unauthorized {
                    var response: SearchUserResponse?
                    try await TokenAPI.shared.generateTokens {
                        let result = try await searchUserTask(searchTerm, page: page, per: per)
                        switch result {
                            case let .success(rsp):
                                response = rsp
                            case let .failure(statusCode):
                                throw generateError(code: Int(statusCode.code), description: statusCode.localizedDescription)
                        }
                    }
                    guard let response = response else {
                        throw generateError(code: 1, description: "Unknows error")
                    }

                    return PaginationResult(response.users, response.metadata)
                } else {
                    throw generateError(code: Int(statusCode.code), description: statusCode.localizedDescription)
                }
        }
    }
}

// MARK: Private Methods -
private extension SearchAPI {
    
    private func searchUserTask(_ searchTerm: String, page: Int, per: Int) async throws -> Result<SearchUserResponse, HTTPStatus>{
        guard let token = try Keychain().get("accessToken") else {
            fatalError()
        }
        
        let route: SearchRoute = .user(searchTerm)
        let url = urlBuilder.searchURL(route: route, version: .v1, page: page, per: per)
        
        var headers = HTTPHeaders()
        headers.add(.authorization(bearerToken: token))
        
        let task = AF
            .request(url, method: .get, headers: headers)
            .serializingDecodable(Response<SearchUserResponse>.self)
        
        let response = await task.response
        
        guard let statusCode = response.response?.statusCode else {
            throw NSError(domain: "Status Code not Available", code: 1)
        }
        
        switch response.result {
            case let .success(response):
                return .success(response.result!)
            case .failure(_):
                return .failure(HTTPStatus(statusCode: statusCode))
        }
    }
    
    // Handle Errors
    private func generateError(code: Int = 1, description: String) -> Error {
        NSError(domain: "SearchAPI", code: code, userInfo: [NSLocalizedDescriptionKey: description])
    }
}
