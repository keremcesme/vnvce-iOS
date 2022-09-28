//
//  URLBuilder+User.swift
//  vnvce
//
//  Created by Kerem Cesme on 28.09.2022.
//

import Foundation

// MARK: 'User' URL Builder
extension URLBuilder {
    public func generateUserURL(route user: UserRoute, version: APIVersion) -> URL {
        let url = generateUserURLString(route: user, version: version)
        
        return URL(string: url)!
    }
}

private extension URLBuilder {
    private func generateUserURLString(route user: UserRoute, version: APIVersion) -> String {
        var urlString = WebConstants.url
        urlString += "/api/"
        urlString += "\(version.rawValue)/"
        urlString += "\(user.raw)"
        
        return urlString
    }
}
