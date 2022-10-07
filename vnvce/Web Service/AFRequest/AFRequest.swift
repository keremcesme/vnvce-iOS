//
//  AFRequest.swift
//  vnvce
//
//  Created by Kerem Cesme on 7.10.2022.
//

import Foundation
import KeychainAccess
import Alamofire
import NIOCore

// MARK: AFRequest struct for Alamofire helper
struct AFRequest {
    static let shared = AFRequest()
    
    private init() {}
    
    public let keychain = Keychain()
    public let encoder = JSONParameterEncoder.default
}

// MARK: Public Request Methods
extension AFRequest: AFRequestTaskProtocol {
    public func task<T: Decodable, E: Encodable>(
        payload: E,
        url: URL,
        method: HTTPMethod,
        authorization: Bool = true,
        to: T.Type
    ) async throws -> Result<T, HTTPStatus> {
        let dataTask = try generateDataTask(
            payload: payload,
            url: url,
            method: method,
            authorization: authorization,
            to: to)
        return try await responseTask(dataTask: dataTask)
    }
    
    public func paginationTask<T: Decodable, E: Encodable>(
        payload: E,
        url: URL,
        method: HTTPMethod,
        authorization: Bool = true,
        to: T.Type
    ) async throws -> Result<Pagination<T>, HTTPStatus> {
        let dataTask = try generatePaginationDataTask(
            payload: payload,
            url: url,
            method: method,
            authorization: authorization,
            to: to)
        return try await paginationResponseTask(dataTask: dataTask)
    }
}

// MARK: Generate 'DataTask' object before to request task
extension AFRequest: AFRequestDataTaskProtocol {
    internal func generateDataTask<T: Decodable, E: Encodable>(
        payload: E?,
        url: URL,
        method: HTTPMethod,
        authorization: Bool,
        to: T.Type
    ) throws -> DataTask<Response<T>> {
        var headers = HTTPHeaders()
        
        if authorization {
            guard let token = try Keychain().get("accessToken") else {
                fatalError()
            }
            headers.add(.authorization(bearerToken: token))
        }
        
        if let payload {
            headers.add(.contentType(MIMEType.appJSON))
            
            return AF
                .request(
                    url,
                    method: method,
                    parameters: payload,
                    encoder: encoder,
                    headers: headers)
                .serializingDecodable(Response<T>.self)
        } else {
            return AF
                .request(
                    url,
                    method: method,
                    headers: headers)
                .serializingDecodable(Response<T>.self)
        }
    }
    
    internal func generatePaginationDataTask<T: Decodable, E: Encodable>(
        payload: E?,
        url: URL,
        method: HTTPMethod,
        authorization: Bool,
        to: T.Type
    ) throws -> DataTask<PaginationResponse<T>> {
        var headers = HTTPHeaders()
        
        if authorization {
            guard let token = try Keychain().get("accessToken") else {
                fatalError()
            }
            headers.add(.authorization(bearerToken: token))
        }
        
        if let payload {
            headers.add(.contentType(MIMEType.appJSON))
            
            return AF
                .request(
                    url,
                    method: method,
                    parameters: payload,
                    encoder: encoder,
                    headers: headers)
                .serializingDecodable(PaginationResponse<T>.self)
        } else {
            return AF
                .request(
                    url,
                    method: method,
                    headers: headers)
                .serializingDecodable(PaginationResponse<T>.self)
        }
    }
}

// MARK: Return task response for specific response types: 'Response' and 'PaginationResponse'
extension AFRequest: AFRequestResponseProtocol {
    func responseTask<T: Decodable>(
        dataTask: DataTask<Response<T>>
    ) async throws -> Result<T, HTTPStatus>  {
        let taskResponse = await dataTask.response
        
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
    
    func paginationResponseTask<T: Decodable>(
        dataTask: DataTask<PaginationResponse<T>>
    ) async throws -> Result<Pagination<T>, HTTPStatus>  {
        let taskResponse = await dataTask.response
        
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
}
