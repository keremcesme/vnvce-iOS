//
//  URLBuilder+Moment.swift
//  vnvce
//
//  Created by Kerem Cesme on 24.10.2022.
//

import Foundation

import Foundation

// MARK: 'Moment' URL Builder
extension URLBuilder {
    public func generateMomentURL(route moment: MomentRoute, version: APIVersion) -> URL {
        let url = generateMomentURLString(route: moment, version: version)
        
        return URL(string: url)!
    }
}

private extension URLBuilder {
    private func generateMomentURLString(route moment: MomentRoute, version: APIVersion) -> String {
        var urlString = WebConstants.url
        urlString += "/api/"
        urlString += "\(version.rawValue)/"
        urlString += "\(moment.raw)"
        
        return urlString
    }
}
