//
//  URLBuilder+Token.swift
//  vnvce
//
//  Created by Kerem Cesme on 22.08.2022.
//

import Foundation

// MARK: 'Token' URL Builder -
extension URLBuilder {
    public func generateTokenURL(route token: TokenRoute, version: APIVersion) -> URL {
        let url = generateTokenURLString(route: token, version: version)
        
        return URL(string: url)!
    }
}

private extension URLBuilder {
    private func generateTokenURLString(route token: TokenRoute, version: APIVersion) -> String {
        var urlString = WebConstants.url
        urlString += "/api/"
        urlString += "\(version.rawValue)/"
        
        switch token {
            case .generate:
                urlString += "\(token.raw)/"
                return urlString
        }
    }
    
}
