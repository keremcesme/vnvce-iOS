//
//  URLRequestBuilder.swift
//  vnvce
//
//  Created by Kerem Cesme on 18.08.2022.
//

import Foundation
import KeychainAccess

struct URLRequestBuilder {
    static let shared = URLRequestBuilder()
    
    private init() {}
}

// MARK: Public Methods -
extension URLRequestBuilder {
    
    public func urlRequest(
        url: URL,
        method: HTTPMethods,
        data: Data? = nil,
        with authorization: Bool = true
    ) throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        if authorization {
            guard let token = try Keychain().get("accessToken") else {
                throw generateError(description: "Access Token not retrived from keychain.")
            }
            request.addValue(MIMEType.Bearer.rawValue + token, forHTTPHeaderField: HTTPHeaders.authorization.rawValue)
        }
        
        if let payload = data {
            request.addValue(MIMEType.JSON.rawValue, forHTTPHeaderField: HTTPHeaders.contentType.rawValue)
            request.httpBody = payload
        }
        
        return request
    }
    
    public func urlRequest<T: Encodable>(
        url: URL,
        method: HTTPMethods,
        payload: T,
        with authorization: Bool = true
    ) throws -> URLRequest {
        let payload = try payload.encode()
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addValue(MIMEType.JSON.rawValue, forHTTPHeaderField: HTTPHeaders.contentType.rawValue)
        request.httpBody = payload
        
        if authorization {
            guard let token = try Keychain().get("accessToken") else {
                throw generateError(description: "Access Token not retrived from keychain.")
            }
            request.addValue(MIMEType.Bearer.rawValue + token, forHTTPHeaderField: HTTPHeaders.authorization.rawValue)
        }
        
        return request
    }
}

// MARK: Private Methods -
private extension URLRequestBuilder {
    private func generateError(code: Int = 1, description: String) -> Error {
        NSError(domain: "URLRequestBuilder", code: code, userInfo: [NSLocalizedDescriptionKey: description])
    }
}

extension URL {
    func convertToURLRequest(
        method: HTTPMethods,
        data: Data? = nil,
        with authorization: Bool = true
    ) throws -> URLRequest {
        return try URLRequestBuilder.shared.urlRequest(url: self, method: method, data: data, with: authorization)
    }
    
    func convertToURLRequest<T: Encodable>(
        method: HTTPMethods,
        payload: T,
        with authorization: Bool = true
    ) throws -> URLRequest {
        return try URLRequestBuilder.shared.urlRequest(url: self, method: method, payload: payload, with: authorization)
    }
}
