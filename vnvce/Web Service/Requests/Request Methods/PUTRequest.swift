//
//  PUTRequest.swift
//  vnvce
//
//  Created by Kerem Cesme on 18.08.2022.
//

import Foundation

// MARK: For URLs
extension Request {
    // MARK: Option 1
    public func put<E: Encodable, D: Decodable>(
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
            method: .PUT)
    }
    
    // MARK: Option 2
    public func put<E: Encodable>(
        url: URL,
        payload: E,
        authorization: Bool = true
    ) async throws -> HTTPURLSessionResponse {
        return try await general(
            url: url,
            payload: payload,
            authorization: authorization,
            method: .PUT)
    }
    
    // MARK: Option 3
    public func put<D: Decodable>(
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
            method: .PUT)
    }
    
    // MARK: Option 4
    public func put(
        url: URL,
        data: Data? = nil,
        authorization: Bool = true
    ) async throws -> HTTPURLSessionResponse {
        return try await general(
            url: url,
            data: data,
            authorization: authorization,
            method: .PUT)
    }
}

// MARK: For URL Requests
extension Request {
    // MARK: Option 1
    public func put<D: Decodable>(
        urlRequest: URLRequest,
        decode to: D.Type
    ) async throws -> HTTPResponse<D> {
        return try await general(
            urlRequest: urlRequest,
            decode: to.self,
            method: .PUT)
    }
    
    // MARK: Option 2
    public func put(
        urlRequest: URLRequest
    ) async throws -> HTTPURLSessionResponse {
        return try await general(
            urlRequest: urlRequest,
            method: .PUT)
    }
}

extension URL {
    
    // MARK: Option 1
    func put<E: Encodable, D: Decodable>(
        payload: E,
        authorization: Bool = true,
        decode to: D.Type
    ) async throws -> HTTPResponse<D> {
        return try await Request.shared.put(
            url: self,
            payload: payload,
            authorization: authorization,
            decode: to.self)
    }
    
    // MARK: Option 2
    func put<E: Encodable>(
        payload: E,
        authorization: Bool = true
    ) async throws -> HTTPURLSessionResponse {
        return try await Request.shared.put(
            url: self,
            payload: payload,
            authorization: authorization)
    }
    
    // MARK: Option 3
    func put<D: Decodable>(
        data: Data? = nil,
        authorization: Bool = true,
        decode to: D.Type
    ) async throws -> HTTPResponse<D> {
        return try await Request.shared.put(
            url: self,
            data: data,
            authorization: authorization,
            decode: to.self)
    }
    
    // MARK: Option 4
    func put(
        data: Data? = nil,
        authorization: Bool = true
    ) async throws -> HTTPURLSessionResponse {
        return try await Request.shared.put(
            url: self,
            data: data,
            authorization: authorization)
    }
}

extension URLRequest {
    // MARK: Option 1
    func put<D: Decodable>(decode to: D.Type) async throws -> HTTPResponse<D> {
        return try await Request.shared.put(
            urlRequest: self,
            decode: to.self)
    }
    
    // MARK: Option 2
    func put() async throws -> HTTPURLSessionResponse {
        return try await Request.shared.put(urlRequest: self)
    }
}
