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

struct SearchAPIOLD {
    static let shared = SearchAPIOLD()
    
    private init() {}
    
    public let keychain = Keychain()
    public let urlBuilder = URLBuilder.shared
    public let encoder = JSONParameterEncoder.default
}

// MARK: Public Methods -
extension SearchAPIOLD {
    public func searchUser(_ searchTerm: String, page: Int, per: Int) async throws -> Pagination<User.PublicOLD> {
        
        let result = try await searchUserTask(searchTerm, page: page, per: per)
        
        switch result {
            case let .success(response):
                return response
            case let .failure(statusCode):
                if statusCode == .unauthorized {
                    let response = try await TokenAPI.shared.retryTask(to: Pagination<User.PublicOLD>.self) {
                        switch try await searchUserTask(searchTerm, page: page, per: per) {
                            case let .success(response):
                                return response
                            case let .failure(statusCode):
                                throw generateError(code: Int(statusCode.code), description: statusCode.localizedDescription)
                        }
                    }
                    
                    return response
                } else {
                    throw generateError(code: Int(statusCode.code), description: statusCode.localizedDescription)
                }
        }
    }
}

// MARK: Private Methods -
private extension SearchAPIOLD {
    
    private func searchUserTask(
        _ searchTerm: String, page: Int, per: Int
    ) async throws -> Result<Pagination<User.PublicOLD>, HTTPStatus>{
        guard let token = try Keychain().get("accessToken") else {
            fatalError()
        }
        
        let url = urlBuilder.searchURL(route: .user, version: .v1, page: page, per: per)
        
        var headers = HTTPHeaders()
        headers.add(.authorization(bearerToken: token))
        headers.add(.contentType(MIMEType.appJSON))
        
        let task = AF
            .request(
                url,
                method: .post,
                parameters: searchTerm,
                encoder: encoder,
                headers: headers)
            .serializingDecodable(PaginationResponseOLD<User.PublicOLD>.self)
        
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
        NSError(domain: "SearchAPI", code: code, userInfo: [NSLocalizedDescriptionKey: description])
    }
}
