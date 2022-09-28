//
//  URLBuilder.swift
//  vnvce
//
//  Created by Kerem Cesme on 18.08.2022.
//

import Foundation

protocol URLBuilderProtocol {
    func authURL(route auth: AuthRoute, version: APIVersion) -> URL
    func tokenURL(route token: TokenRoute, version: APIVersion) -> URL
    func meURL(route me: MeRoute, version: APIVersion) -> URL
    func searchURL(route search: SearchRoute, version: APIVersion, page: Int, per: Int) -> URL
    func postURL(route post: PostRoute, version: APIVersion) -> URL
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
    
    func tokenURL(route token: TokenRoute, version: APIVersion) -> URL {
        generateTokenURL(route: token, version: version)
    }
    
    func meURL(route me: MeRoute, version: APIVersion) -> URL {
        generateMeURL(route: me, version: version)
    }
    
    func searchURL(route search: SearchRoute, version: APIVersion, page: Int, per: Int) -> URL {
        generateSearchURL(route: search, version: version, page: page, per: per)
    }
    
    func postURL(route post: PostRoute, version: APIVersion) -> URL {
        generatePostURL(route: post, version: version)
    }
    
    func relationshipURL(route relationship: RelationshipRoute, version: APIVersion) -> URL {
        generateRelationshipURL(route: relationship, version: version)
    }
    
    func userURL(route user: UserRoute, version: APIVersion) -> URL {
        generateUserURL(route: user, version: version)
    }
    
}

// MARK: Pagination Params -
extension URLBuilder {
    func paginationParams(page: Int, per: Int) -> String {
        return "/?page=\(page)&per=\(per)"
    }
}
