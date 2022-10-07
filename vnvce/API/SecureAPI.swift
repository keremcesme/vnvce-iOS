//
//  SecureAPI.swift
//  vnvce
//
//  Created by Kerem Cesme on 7.10.2022.
//

import Foundation

protocol SecureAPIProtocol {
    func task<T: Decodable>(
        _ task: @escaping () async throws -> Result<T, HTTPStatus>,
        decode to: T.Type
    ) async throws -> T
    
    func task<T: Decodable, E: Encodable>(
        payload: E,
        _ task: @escaping (E) async throws -> Result<T, HTTPStatus>,
        decode to: T.Type
    ) async throws -> T
    
    func task<T: Decodable>(
        pagination params: PaginationParams,
        _ task: @escaping (PaginationParams) async throws -> Result<T, HTTPStatus>,
        decode to: T.Type
    ) async throws -> T
    
    func task<T: Decodable, E: Encodable>(
        payload: E,
        pagination params: PaginationParams,
        _ task: @escaping (E, PaginationParams) async throws -> Result<T, HTTPStatus>,
        decode to: T.Type
    ) async throws -> T
    
    func finalTask<T: Decodable>(
        result: Result<T, HTTPStatus>,
        retryTask: @escaping () async throws -> Result<T, HTTPStatus>
    ) async throws -> T
    
}

struct SecureAPI {
    static let shared = SecureAPI()
    
    private init() {}
    
    public let tokenAPI = TokenAPI.shared
}

extension SecureAPI: SecureAPIProtocol {
    func task<T>(
        _ task: @escaping () async throws -> Result<T, HTTPStatus>,
        decode to: T.Type
    ) async throws -> T where T: Decodable {
        let result = try await task()
        return try await finalTask(result: result, retryTask: {try await task()})
    }
    
    func task<T, E>(
        payload: E, _ task: @escaping (E) async throws -> Result<T, HTTPStatus>,
        decode to: T.Type
    ) async throws -> T where T: Decodable, E: Encodable {
        let result = try await task(payload)
        return try await finalTask(result: result, retryTask: {try await task(payload)})
    }
    
    func task<T>(
        pagination params: PaginationParams,
        _ task: @escaping (PaginationParams) async throws -> Result<T, HTTPStatus>,
        decode to: T.Type
    ) async throws -> T where T : Decodable {
        let result = try await task(params)
        return try await finalTask(result: result, retryTask: {try await task(params)})
    }
    
    func task<T, E>(
        payload: E,
        pagination params: PaginationParams,
        _ task: @escaping (E, PaginationParams) async throws -> Result<T, HTTPStatus>,
        decode to: T.Type
    ) async throws -> T where T: Decodable, E: Encodable {
        let result = try await task(payload, params)
        return try await finalTask(result: result, retryTask: {try await task(payload, params)})
    }
    
    internal func finalTask<T: Decodable>(
        result: Result<T, HTTPStatus>,
        retryTask: @escaping () async throws -> Result<T, HTTPStatus>
    ) async throws -> T {
        switch result {
        case let .success(response):
            return response
        case let .failure(statusCode):
            if statusCode == .unauthorized {
                let response = try await tokenAPI.retryTask(to: T.self) {
                    switch try await retryTask() {
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
    
    // Handle Errors
    private func generateError(code: Int = 1, description: String) -> Error {
        NSError(domain: "SecureAPI", code: code, userInfo: [NSLocalizedDescriptionKey: description])
    }
    
}
