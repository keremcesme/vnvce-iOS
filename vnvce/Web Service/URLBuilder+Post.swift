//
//  URLBuilder+Post.swift
//  vnvce
//
//  Created by Kerem Cesme on 13.09.2022.
//

import Foundation

// MARK: 'Post' URL Builder
extension URLBuilder {
    public func generatePostURL(route post: PostRoute, version: APIVersion) -> URL {
        let url = generatePostURLString(route: post, version: version)
        
        return URL(string: url)!
    }
}

private extension URLBuilder {
    private func generatePostURLString(route post: PostRoute, version: APIVersion) -> String {
        var urlString = WebConstants.url
        urlString += "/api/"
        urlString += "\(version.rawValue)/"
        urlString += "\(post.raw)"
        
        return urlString
    }
}
