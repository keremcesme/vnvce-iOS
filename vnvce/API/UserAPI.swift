//
//  UserAPI.swift
//  vnvce
//
//  Created by Kerem Cesme on 28.09.2022.
//

import Foundation

struct UserAPI {
    static let shared = UserAPI()
    
    private init() {}
    
    public let urlBuilder = URLBuilder.shared
    public let request = AFRequest.shared
    public let secureAPI = SecureAPI.shared
}

// MARK: Public Methods -
extension UserAPI {
    
    public func fetchProfile(userID: String) async throws -> User.Public {
        return try await secureAPI.task({
            try await fetchProfileTask(userID)
        }, decode: User.Public.self)
    }
    
}

// MARK: Private Methods -
extension UserAPI {
    private func fetchProfileTask(_ userID: String) async throws -> Result<User.Public, HTTPStatus> {
        var url = urlBuilder.userURL(route: .profile(userID: userID), version: .v1)
        return try await request.task(
            url: url,
            method: .post,
            to: User.Public.self)
    }
}
