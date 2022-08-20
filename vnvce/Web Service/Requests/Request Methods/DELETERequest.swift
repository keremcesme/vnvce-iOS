//
//  DELETERequest.swift
//  vnvce
//
//  Created by Kerem Cesme on 18.08.2022.
//

import Foundation

// MARK: For URLs
extension Request {
    
    // MARK: Option 1
    public func delete<E: Encodable, D: Decodable>(
        url: URL,
        payload: E,
        authorization: Bool = true,
        decode to: D.Type
    ) async throws -> HTTPResponse<D> {
        return try await general(
            url: url,
            payload: payload,
            authorization: authorization,
            decode: to.self,
            method: .DELETE)
    }
    
    // MARK: Option 2
    public func delete<E: Encodable>(
        url: URL,
        payload: E,
        authorization: Bool = true
    ) async throws -> HTTPURLSessionResponse {
        return try await general(
            url: url,
            payload: payload,
            authorization: authorization,
            method: .DELETE)
    }
    
    // MARK: Option 3
    public func delete<D: Decodable>(
        url: URL,
        data: Data? = nil,
        authorization: Bool = true,
        decode to: D.Type
    ) async throws -> HTTPResponse<D> {
        return try await general(
            url: url,
            data: data,
            authorization: authorization,
            decode: to.self,
            method: .DELETE)
    }
    
    // MARK: Option 4
    public func delete(
        url: URL,
        data: Data? = nil,
        authorization: Bool = true
    ) async throws -> HTTPURLSessionResponse {
        return try await general(
            url: url,
            data: data,
            authorization: authorization,
            method: .DELETE)
    }
}

// MARK: For URL Requests
extension Request {
    // MARK: Option 1
    public func delete<D: Decodable>(
        urlRequest: URLRequest,
        decode to: D.Type
    ) async throws -> HTTPResponse<D> {
        return try await general(
            urlRequest: urlRequest,
            decode: to.self,
            method: .DELETE)
    }
    
    // MARK: Option 2
    public func delete(
        urlRequest: URLRequest
    ) async throws -> HTTPURLSessionResponse {
        return try await general(
            urlRequest: urlRequest,
            method: .DELETE)
    }
    
}

extension URL {
    
    // MARK: Option 1
    func delete<E: Encodable, D: Decodable>(
        payload: E,
        authorization: Bool = true,
        decode to: D.Type
    ) async throws -> HTTPResponse<D> {
        return try await Request.shared.delete(
            url: self,
            payload: payload,
            authorization: authorization,
            decode: to.self)
    }
    
    // MARK: Option 2
    func delete<E: Encodable>(
        payload: E,
        authorization: Bool = true
    ) async throws -> HTTPURLSessionResponse {
        return try await Request.shared.delete(
            url: self,
            payload: payload,
            authorization: authorization)
    }
    
    // MARK: Option 3
    func delete<D: Decodable>(
        data: Data? = nil,
        authorization: Bool = true,
        decode to: D.Type
    ) async throws -> HTTPResponse<D> {
        return try await Request.shared.delete(
            url: self,
            data: data,
            authorization: authorization,
            decode: to.self)
    }
    
    // MARK: Option 4
    func delete(
        data: Data? = nil,
        authorization: Bool = true
    ) async throws -> HTTPURLSessionResponse {
        return try await Request.shared.delete(
            url: self,
            data: data,
            authorization: authorization)
    }
}

extension URLRequest {
    // MARK: Option 1
    func delete<D: Decodable>(decode to: D.Type) async throws -> HTTPResponse<D> {
        return try await Request.shared.delete(
            urlRequest: self,
            decode: to.self)
    }
    
    // MARK: Option 2
    func delete() async throws -> HTTPURLSessionResponse {
        return try await Request.shared.delete(urlRequest: self)
    }
}
