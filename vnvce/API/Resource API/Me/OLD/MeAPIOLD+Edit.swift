//
//  MeAPIOLD+Edit.swift
//  vnvce
//
//  Created by Kerem Cesme on 23.08.2022.
//

import Foundation
import KeychainAccess
import Alamofire
import NIOCore


// MARK: Public Methods -
extension MeAPIOLD {
    public func editProfilePicture(payload: EditProfilePicturePayload) async throws {
        let statusCode = try await editProfilePictureTask(payload)
        
        if statusCode == .unauthorized {
            try await TokenAPI.shared.generateTokens {
                _ = try await editProfilePictureTask(payload)
            }
        }
    }
    
    public func editDisplayName(displayName: String) async throws {
        let statusCode = try await editDisplayNameTask(displayName)
        
        if statusCode == .unauthorized {
            try await TokenAPI.shared.generateTokens {
                _ = try await editDisplayNameTask(displayName)
            }
        }
    }
    
    public func editBiography(biography: String) async throws {
        let statusCode = try await editBiographyTask(biography)
        
        if statusCode == .unauthorized {
            try await TokenAPI.shared.generateTokens {
                _ = try await editBiographyTask(biography)
            }
        }
    }
}

// MARK: Private Methods -
extension MeAPIOLD {
    private func editProfilePictureTask(_ payload: EditProfilePicturePayload) async throws -> HTTPStatus {
        
        guard let token = try Keychain().get("accessToken") else {
            fatalError()
        }
        
        let route: MeRoute = .edit(.profilePicture)
        let url = urlBuilder.meURL(route: route, version: .v1)
        
        
        var headers = HTTPHeaders()
        headers.add(.authorization(bearerToken: token))
        headers.add(.contentType(MIMEType.appJSON))
        
        let task = AF
            .request(
                url,
                method: .put,
                parameters: payload,
                encoder: encoder,
                headers: headers)
            .serializingData()
        
        let response = await task.response
        
        guard let statusCode = response.response?.statusCode else {
            throw NSError(domain: "Status Code not Available", code: 1)
        }
        
        return HTTPStatus(statusCode: statusCode)
    }
    
    private func editDisplayNameTask(_ displayName: String) async throws -> HTTPStatus {
        guard let token = try Keychain().get("accessToken") else {
            fatalError()
        }
        
        let route: MeRoute = .edit(.displayName)
        let url = urlBuilder.meURL(route: route, version: .v1)
        
        var headers = HTTPHeaders()
        headers.add(.authorization(bearerToken: token))
        headers.add(.contentType(MIMEType.appJSON))
        
        let task = AF
            .request(
                url,
                method: .patch,
                parameters: displayName,
                encoder: encoder,
                headers: headers)
            .serializingData()
        
        let response = await task.response
        
        guard let statusCode = response.response?.statusCode else {
            throw NSError(domain: "Status Code not Available", code: 1)
        }
        
        return HTTPStatus(statusCode: statusCode)
    }
    
    private func editBiographyTask(_ biography: String) async throws -> HTTPStatus {
        guard let token = try Keychain().get("accessToken") else {
            fatalError()
        }
        
        let route: MeRoute = .edit(.biography)
        let url = urlBuilder.meURL(route: route, version: .v1)
        
        var headers = HTTPHeaders()
        headers.add(.authorization(bearerToken: token))
        headers.add(.contentType(MIMEType.appJSON))
        
        let task = AF
            .request(
                url,
                method: .patch,
                parameters: biography,
                encoder: encoder,
                headers: headers)
            .serializingData()
        
        let response = await task.response
        
        guard let statusCode = response.response?.statusCode else {
            throw NSError(domain: "Status Code not Available", code: 1)
        }
        return HTTPStatus(statusCode: statusCode)
    }
    
    
    
}
