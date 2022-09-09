//
//  URLBuilder+Auth.swift
//  vnvce
//
//  Created by Kerem Cesme on 18.08.2022.
//

import Foundation

// MARK: 'Auth' URL Builder -
extension URLBuilder {
    public func generateAuthURL(route auth: AuthRoute, version: APIVersion) -> URL {
        let url = generateAuthURLString(route: auth, version: version)
        
        return URL(string: url)!
    }
}

private extension URLBuilder {
    private func generateAuthURLString(route auth: AuthRoute, version: APIVersion) -> String {
        var urlString = WebConstants.url
        urlString += "/api/"
        urlString += "\(version.rawValue)/"
        urlString += "\(auth.raw)/"
        
        switch auth {
            case let .create(create):        
                urlString += "\(create.raw)/"
                switch create {
                    case let .phone(phone):
                        urlString += "\(phone.raw)/"
                        return urlString
                    case let .username(username):
                        urlString += "\(username.raw)/"
                        return urlString
                    case .reserveUsernameAndSendOTP:
                        return urlString
                    case .newAccount:
                        return urlString
                }
            case .login:
                return urlString
        }
    }
    
}
