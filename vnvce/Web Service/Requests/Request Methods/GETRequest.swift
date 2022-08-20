//
//  GETRequest.swift
//  vnvce
//
//  Created by Kerem Cesme on 18.08.2022.
//

import Foundation

extension Request {
    
    // MARK: Option 1
    public func get<D: Decodable>(
        url: URL,
        authorization: Bool = true,
        decode to: D.Type
    ) async throws -> HTTPResponse<D> {
        return try await general(
            url: url,
            data: nil,
            authorization: authorization,
            decode: to.self,
            method: .POST)
    }
    
    // MARK: Option 2
    public func get(
        url: URL,
        authorization: Bool = true
    ) async throws -> HTTPURLSessionResponse {
        return try await general(
            url: url,
            data: nil,
            authorization: authorization,
            method: .POST)
    }
    
    // MARK: Option 3
    public func get<D: Decodable>(
        url: URL,
        decode to: D.Type
    ) async throws -> HTTPResponse<D> {
        return try await general(
            url: url,
            decode: to.self)
    }
    
    // MARK: Option 4
    public func get(
        url: URL
    ) async throws -> HTTPURLSessionResponse {
        return try await general(
            url: url)
    }
}

extension URL {
    
    // MARK: Option 1
    func get<D: Decodable>(
        authorization: Bool = true,
        decode to: D.Type
    ) async throws -> HTTPResponse<D> {
        return try await Request.shared.get(
            url: self,
            authorization: authorization,
            decode: to.self)
    }
    
    // MARK: Option 2
    func get(
        authorization: Bool = true
    ) async throws -> HTTPURLSessionResponse {
        return try await Request.shared.get(
            url: self,
            authorization: authorization)
    }
    
    // MARK: Option 3
    func get<D: Decodable>(
        decode to: D.Type
    ) async throws -> HTTPResponse<D> {
        return try await Request.shared.get(
            url: self,
            decode: to.self)
    }
    
    // MARK: Option 4
    func get() async throws -> HTTPURLSessionResponse {
        return try await Request.shared.get(
            url: self)
    }
}
