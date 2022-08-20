//
//  PATCHRequest.swift
//  vnvce
//
//  Created by Kerem Cesme on 18.08.2022.
//

import Foundation

// MARK: For URLs
extension Request {
    
    // MARK: Option 1
    public func patch<E: Encodable, D: Decodable>(
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
            method: .PATCH)
    }
    
    // MARK: Option 2
    public func patch<E: Encodable>(
        url: URL,
        payload: E,
        authorization: Bool = true
    ) async throws -> HTTPURLSessionResponse {
        return try await general(
            url: url,
            payload: payload,
            authorization: authorization,
            method: .PATCH)
    }
    
    // MARK: Option 3
    public func patch<D: Decodable>(
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
            method: .PATCH)
    }
    
    // MARK: Option 4
    public func patch(
        url: URL,
        data: Data? = nil,
        authorization: Bool = true
    ) async throws -> HTTPURLSessionResponse {
        return try await general(
            url: url,
            data: data,
            authorization: authorization,
            method: .PATCH)
    }
}

// MARK: For URL Requests
extension Request {
    // MARK: Option 1
    public func patch<D: Decodable>(
        urlRequest: URLRequest,
        decode to: D.Type
    ) async throws -> HTTPResponse<D> {
        return try await general(
            urlRequest: urlRequest,
            decode: to.self,
            method: .PATCH)
    }
    
    // MARK: Option 2
    public func patch(
        urlRequest: URLRequest
    ) async throws -> HTTPURLSessionResponse {
        return try await general(
            urlRequest: urlRequest,
            method: .PATCH)
    }
    
}

extension URL {
    
    // MARK: Option 1
    func patch<E: Encodable, D: Decodable>(
        payload: E,
        authorization: Bool = true,
        decode to: D.Type
    ) async throws -> HTTPResponse<D> {
        return try await Request.shared.patch(
            url: self,
            payload: payload,
            authorization: authorization,
            decode: to.self)
    }
    
    // MARK: Option 2
    func patch<E: Encodable>(
        payload: E,
        authorization: Bool = true
    ) async throws -> HTTPURLSessionResponse {
        return try await Request.shared.patch(
            url: self,
            payload: payload,
            authorization: authorization)
    }
    
    // MARK: Option 3
    func patch<D: Decodable>(
        data: Data? = nil,
        authorization: Bool = true,
        decode to: D.Type
    ) async throws -> HTTPResponse<D> {
        return try await Request.shared.patch(
            url: self,
            data: data,
            authorization: authorization,
            decode: to.self)
    }
    
    // MARK: Option 4
    func patch(
        data: Data? = nil,
        authorization: Bool = true
    ) async throws -> HTTPURLSessionResponse {
        return try await Request.shared.patch(
            url: self,
            data: data,
            authorization: authorization)
    }
}

extension URLRequest {
    // MARK: Option 1
    func patch<D: Decodable>(decode to: D.Type) async throws -> HTTPResponse<D> {
        return try await Request.shared.patch(
            urlRequest: self,
            decode: to.self)
    }
    
    // MARK: Option 2
    func patch() async throws -> HTTPURLSessionResponse {
        return try await Request.shared.patch(urlRequest: self)
    }
}
