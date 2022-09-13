//
//  URLBuilder+Search.swift
//  vnvce
//
//  Created by Kerem Cesme on 10.09.2022.
//

import Foundation

// MARK: 'Search' URL Builder -
extension URLBuilder {
    public func generateSearchURL(route search: SearchRoute, version: APIVersion, page: Int, per: Int) -> URL {
        let url = generateSearchURLString(route: search, version: version, page: page, per: per)
        
        return URL(string: url)!
    }
}

private extension URLBuilder {
    private func generateSearchURLString(route search: SearchRoute, version: APIVersion, page: Int, per: Int) -> String {
        var urlString = WebConstants.url
        urlString += "/api/"
        urlString += "\(version.rawValue)/"
        urlString += "\(search.raw)"
        
        switch search {
            case .user:
                urlString += paginationParams(page: page, per: per)
                return urlString
        }
    }
}
