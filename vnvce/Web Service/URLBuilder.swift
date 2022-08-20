//
//  URLBuilder.swift
//  vnvce
//
//  Created by Kerem Cesme on 18.08.2022.
//

import Foundation

protocol URLBuilderProtocol {
    func authURL(route auth: AuthRoute, version: APIVersion) -> URL
}

struct URLBuilder {
    static let shared = URLBuilder()
    
    private init() {}
}

// MARK: Public Methods -
extension URLBuilder: URLBuilderProtocol {
    func authURL(route auth: AuthRoute, version: APIVersion) -> URL {
        generateAuthURL(route: auth, version: version)
    }
}
