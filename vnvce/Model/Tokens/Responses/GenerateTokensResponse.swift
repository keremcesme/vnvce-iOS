//
//  GenerateTokensResponse.swift
//  vnvce
//
//  Created by Kerem Cesme on 22.08.2022.
//

import Foundation

enum TokenGenerateError: String, Decodable {
    case notFound = "No Found Refresh Token in the database"
    case clientIdNotMatch = "Client ID not match."
}

struct GeneratedTokens: Decodable {
    let accessToken: String?
    let refreshToken: String?
    
    init(accessToken: String? = nil,
         refreshToken: String? = nil) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
    
}

extension GeneratedTokens {
    var message: String {
        if accessToken != nil && refreshToken != nil {
           return "Access and Refresh Tokens generated."
        } else if accessToken != nil && refreshToken == nil {
            return "Access Token is generated."
        } else {
            return "Unknown"
        }
    }
}

enum TokenResponse: Decodable {
    case failure(TokenGenerateError)
    case success(GeneratedTokens)
}
