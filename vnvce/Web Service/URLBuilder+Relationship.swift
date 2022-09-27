//
//  URLBuilder+Relationship.swift
//  vnvce
//
//  Created by Kerem Cesme on 25.09.2022.
//

import Foundation

// MARK: 'Relationship' URL Builder
extension URLBuilder {
    public func generateRelationshipURL(
        route relationship: RelationshipRoute,
        version: APIVersion
    ) -> URL {
        let url = generateRelationshipURLString(route: relationship, version: version)
        
        return URL(string: url)!
    }
}

private extension URLBuilder {
    private func generateRelationshipURLString(
        route relationship: RelationshipRoute,
        version: APIVersion
    ) -> String {
        var urlString = WebConstants.url
        urlString += "/api/"
        urlString += "\(version.rawValue)/"
        urlString += "\(relationship.raw)"
        
        return urlString
    }
}
