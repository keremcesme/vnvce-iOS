//
//  Request.swift
//  vnvce
//
//  Created by Kerem Cesme on 18.08.2022.
//

import Foundation
import KeychainAccess

typealias URLSessionResult = (data: Data, response: URLResponse)
typealias HTTPURLSessionResponse = (data: Data, httpResponse: HTTPURLResponse)

typealias HTTPResponse<D: Decodable> = (response: D, httpResponse: HTTPURLSessionResponse)

enum URLRequestType {
    case url(URL)
    case urlRequest(URLRequest)
}

struct Request {
    static let shared = Request()
    
    private init() {}
    
    private let session = URLSession.shared
}

//  MARK: For URLs
extension Request {
    
    // MARK: Option 1
    public func general<E: Encodable, D: Decodable>(
        url: URL,
        payload: E,
        authorization: Bool = true,
        decode to: D.Type,
        method: HTTPMethods
    ) async throws -> HTTPResponse<D> {
        let request = try url.convertToURLRequest(
            method: method,
            payload: payload,
            with: authorization)
        let result = try await send(.urlRequest(request))
        let data = try result.data.decode(D.self)
        return (data, result)
    }
    
    // MARK: Option 2
    public func general<E: Encodable>(
        url: URL,
        payload: E,
        authorization: Bool = true,
        method: HTTPMethods
    ) async throws -> HTTPURLSessionResponse {
        let request = try url.convertToURLRequest(
            method: method,
            payload: payload,
            with: authorization)
        
        let result = try await send(.urlRequest(request))
        
        return result
    }
    
    // MARK: Option 3
    public func general<D: Decodable>(
        url: URL,
        data: Data? = nil,
        authorization: Bool = true,
        decode to: D.Type,
        method: HTTPMethods
    ) async throws -> HTTPResponse<D> {
        let request = try url.convertToURLRequest(
            method: method,
            data: data,
            with: authorization)
        
        let result = try await send(.urlRequest(request))
        
        let data = try result.data.decode(D.self)
        
        return (data, result)
    }
    
    // MARK: Option 4
    public func general(
        url: URL,
        data: Data? = nil,
        authorization: Bool = true,
        method: HTTPMethods
    ) async throws -> HTTPURLSessionResponse {
        let request = try url.convertToURLRequest(
            method: method,
            data: data,
            with: authorization)
        
        let result = try await send(.urlRequest(request))
        
        return result
    }
    
    // MARK: Option 3 (GET Request Only)
    public func general<D: Decodable>(
        url: URL,
        decode to: D.Type
    ) async throws -> HTTPResponse<D> {
        let result = try await send(.url(url))
        let data = try result.data.decode(D.self)
        return (data, result)
    }
    
    // MARK: Option 4 (GET Request Only)
    public func general(
        url: URL
    ) async throws -> HTTPURLSessionResponse {
        let result = try await send(.url(url))
        return result
    }
    
}

//  MARK: For URL Requests
extension Request {
    
    // MARK: Option 1
    public func general<D: Decodable>(
        urlRequest: URLRequest,
        decode to: D.Type,
        method: HTTPMethods
    ) async throws -> HTTPResponse<D> {
        let result = try await send(.urlRequest(urlRequest))
        
        let data = try result.data.decode(D.self)
        
        return (data, result)
    }
    
    // MARK: Option 2
    public func general(
        urlRequest: URLRequest,
        method: HTTPMethods
    ) async throws -> HTTPURLSessionResponse {
        let result = try await send(.urlRequest(urlRequest))
        
        return result
    }
    
}

private extension Request {
    private func send(_ method: URLRequestType) async throws -> HTTPURLSessionResponse {
        let result: URLSessionResult = try await request(method)

        guard let response = result.response as? HTTPURLResponse else {
            throw error(description: "Bad Response")
        }

        switch response.statusCode {
            case (200...299), (400...499):
                let result = HTTPURLSessionResponse(data: result.data, httpResponse: response)
//                print(result.data.json)
                return result
            default:
                throw error(description: "A server error occured")
        }
    }
    
    private func error(code: Int = 1, description: String) -> Error {
        NSError(domain: "Request", code: code, userInfo: [NSLocalizedDescriptionKey: description])
    }
}

// MARK: Requests -
private extension Request {
    private func request(_ method: URLRequestType) async throws -> URLSessionResult {
        if #available(iOS 15.0, *) {
            switch method {
                case let .url(url):
                    return try await session.data(from: url)
                case let .urlRequest(urlRequest):
                    return try await session.data(for: urlRequest)
            }
        } else {
            return try await withCheckedThrowingContinuation { continuation in
                switch method {
                    case let .url(url):
                        let task = session.dataTask(with: url) { data, response, error in
                            guard
                                let data = data,
                                let response = response
                            else {
                                let error = error ?? URLError(.badServerResponse)
                                return continuation.resume(throwing: error)
                            }
                            let result = URLSessionResult(data: data, response: response)
                            continuation.resume(returning: result)
                        }
                        task.resume()
                    case let .urlRequest(urlRequest):
                        let task = session.dataTask(with: urlRequest) { data, response, error in
                            guard
                                let data = data,
                                let response = response
                            else {
                                let error = error ?? URLError(.badServerResponse)
                                return continuation.resume(throwing: error)
                            }
                            let result = URLSessionResult(data: data, response: response)
                            continuation.resume(returning: result)
                        }
                        task.resume()
                }
            }
        }
    }
    
    private func request(from url: URL) async throws -> URLSessionResult {
        if #available(iOS 15.0, *) {
            return try await session.data(from: url)
        } else {
            return try await withCheckedThrowingContinuation { continuation in
                let task = session.dataTask(with: url) { data, response, error in
                    guard
                        let data = data,
                        let response = response
                    else {
                        let error = error ?? URLError(.badServerResponse)
                        return continuation.resume(throwing: error)
                    }
                    let result = URLSessionResult(data: data, response: response)
                    continuation.resume(returning: result)
                }
                task.resume()
            }
        }
    }
    
    private func request(for urlRequest: URLRequest) async throws -> URLSessionResult {
        if #available(iOS 15.0, *) {
            return try await session.data(for: urlRequest)
        } else {
            return try await withCheckedThrowingContinuation { continuation in
                let task = session.dataTask(with: urlRequest) { data, response, error in
                    guard
                        let data = data,
                        let response = response
                    else {
                        let error = error ?? URLError(.badServerResponse)
                        return continuation.resume(throwing: error)
                    }
                    let result = URLSessionResult(data: data, response: response)
                    continuation.resume(returning: result)
                }
                task.resume()
            }
        }
    }
}
