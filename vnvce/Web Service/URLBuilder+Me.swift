//
//  URLBuilder+Me.swift
//  vnvce
//
//  Created by Kerem Cesme on 22.08.2022.
//

import Foundation

// MARK: 'Me' URL Builder -
extension URLBuilder {
    public func generateMeURL(route me: MeRoute, version: APIVersion) -> URL {
        let url = generateMeURLString(route: me, version: version)
        
        return URL(string: url)!
    }
}

private extension URLBuilder {
    private func generateMeURLString(route me: MeRoute, version: APIVersion) -> String {
        var urlString = WebConstants.url
        urlString += "/api/"
        urlString += "\(version.rawValue)/"
        urlString += "\(me.raw)/"
        
        switch me {
            case .profile:
                return urlString
            case let .edit(edit):
                urlString += "\(edit.raw)/"
                return urlString
        }
    }
}
