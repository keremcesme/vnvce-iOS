//
//  POSTRequest.swift
//  vnvce
//
//  Created by Kerem Cesme on 18.08.2022.
//

import Foundation

// MARK: For URLs
extension Request {
    
    // MARK: Option 1
    public func post<E: Encodable, D: Decodable>(
        url: URL,
        payload: E,
        authorization: Bool = true,
        decode to: D.Type
    ) async throws -> HTTPResponse<D>{
        return try await general(
            url: url,
            payload: payload,
            authorization: authorization,
            decode: to.self,
            method: .POST)
    }
    
    // MARK: Option 2
    public func post<E: Encodable>(
        url: URL,
        payload: E,
        authorization: Bool = true
    ) async throws -> HTTPURLSessionResponse {
        return try await general(
            url: url,
            payload: payload,
            authorization: authorization,
            method: .POST)
    }
    
    // MARK: Option 3
    public func post<D: Decodable>(
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
            method: .POST)
    }
    
    // MARK: Option 4
    public func post(
        url: URL,
        data: Data? = nil,
        authorization: Bool = true
    ) async throws -> HTTPURLSessionResponse {
        return try await general(
            url: url,
            data: data,
            authorization: authorization,
            method: .POST)
    }
}

// MARK: For URL Requests
extension Request {
    // MARK: Option 1
    public func post<D: Decodable>(
        urlRequest: URLRequest,
        decode to: D.Type
    ) async throws -> HTTPResponse<D> {
        return try await general(
            urlRequest: urlRequest,
            decode: to.self,
            method: .POST)
    }
    
    // MARK: Option 2
    public func post(
        urlRequest: URLRequest
    ) async throws -> HTTPURLSessionResponse {
        return try await general(
            urlRequest: urlRequest,
            method: .POST)
    }
    
}

extension URL {
    
    // MARK: Option 1
    func post<E: Encodable, D: Decodable>(
        payload: E,
        authorization: Bool = true,
        decode to: D.Type
    ) async throws -> HTTPResponse<D> {
        return try await Request.shared.post(
            url: self,
            payload: payload,
            authorization: authorization,
            decode: to.self)
    }
    
    // MARK: Option 2
    func post<E: Encodable>(
        payload: E,
        authorization: Bool = true
    ) async throws -> HTTPURLSessionResponse {
        return try await Request.shared.post(
            url: self,
            payload: payload,
            authorization: authorization)
    }
    
    // MARK: Option 3
    func post<D: Decodable>(
        data: Data? = nil,
        authorization: Bool = true,
        decode to: D.Type
    ) async throws -> HTTPResponse<D> {
        return try await Request.shared.post(
            url: self,
            data: data,
            authorization: authorization,
            decode: to.self)
    }
    
    // MARK: Option 4
    func post(
        data: Data? = nil,
        authorization: Bool = true
    ) async throws -> HTTPURLSessionResponse {
        return try await Request.shared.post(
            url: self,
            data: data,
            authorization: authorization)
    }
}

extension URLRequest {
    // MARK: Option 1
    func post<D: Decodable>(decode to: D.Type) async throws -> HTTPResponse<D> {
        return try await Request.shared.post(
            urlRequest: self,
            decode: to.self)
    }
    
    // MARK: Option 2
    func post() async throws -> HTTPURLSessionResponse {
        return try await Request.shared.post(urlRequest: self)
    }
}
