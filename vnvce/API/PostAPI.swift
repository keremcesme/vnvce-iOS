//
//  PostAPI.swift
//  vnvce
//
//  Created by Kerem Cesme on 13.09.2022.
//

import Foundation
import KeychainAccess
import Alamofire
import NIOCore

struct PostAPI {
    static let shared = PostAPI()
    
    private init() {}
    
    public let keychain = Keychain()
    public let urlBuilder = URLBuilder.shared
    public let encoder = JSONParameterEncoder.default
}

// MARK: Public Methods -
extension PostAPI {
    
    public func uploadPost(payload: UploadPostPayload) async throws -> Post {
        let result = try await uploadPostTask(payload: payload)
        
        switch result {
        case let .success(response):
            return response
        case let .failure(statusCode):
            if statusCode == .unauthorized {
                let response = try await TokenAPI.shared.retryTask(to: Post.self) {
                    switch try await uploadPostTask(payload: payload) {
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
    
    public func fetchPosts(payload: PostsPayload, params: PaginationParams) async throws -> Pagination<Post> {
        let result = try await fetchPostsTask(payload, params)
        
        switch result {
            case let .success(response):
                return response
            case let .failure(statusCode):
                if statusCode == .unauthorized {
                    let response = try await TokenAPI.shared.retryTask(to: Pagination<Post>.self) {
                        switch try await fetchPostsTask(payload, params) {
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
private extension PostAPI {
    
    private func uploadPostTask(payload: UploadPostPayload) async throws -> Result<Post, HTTPStatus> {
        guard let token = try Keychain().get("accessToken") else {
            fatalError()
        }
        
        let url = urlBuilder.postURL(route: .upload, version: .v1)
        
        var headers = HTTPHeaders()
        headers.add(.authorization(bearerToken: token))
        headers.add(.contentType(MIMEType.appJSON))
        
        let task = AF
            .request(
                url,
                method: .post,
                parameters: payload,
                encoder: encoder,
                headers: headers)
            .serializingDecodable(Response<Post>.self)
        
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
    
    private func fetchPostsTask(_ payload: PostsPayload, _ params: PaginationParams) async throws -> Result<Pagination<Post>, HTTPStatus> {
        guard let token = try Keychain().get("accessToken") else {
            fatalError()
        }
        
        let url = urlBuilder.postURL(route: .posts(params), version: .v1)
        
        var headers = HTTPHeaders()
        headers.add(.authorization(bearerToken: token))
        headers.add(.contentType(MIMEType.appJSON))
        
        let task = AF
            .request(
                url,
                method: .post,
                parameters: payload,
                encoder: encoder,
                headers: headers)
            .serializingDecodable(PaginationResponse<Post>.self)
        
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
        NSError(domain: "PostAPI", code: code, userInfo: [NSLocalizedDescriptionKey: description])
    }
    
}
