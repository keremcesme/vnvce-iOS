//
//  MomentAPI.swift
//  vnvce
//
//  Created by Kerem Cesme on 24.10.2022.
//

import Foundation


struct MomentAPI {
    static let shared = MomentAPI()
    
    private init () {}
    
    public let urlBuilder = URLBuilder.shared
    public let request = AFRequest.shared
    public let secureAPI = SecureAPI.shared
    
}

// MARK: Public Methods -
extension MomentAPI {
    public func uploadMoment(_ payload: UploadMomentPayload) async throws -> Moment {
        return try await secureAPI.task(payload: payload, uploadMomentTask, decode: Moment.self)
    }
    
    public func fetchMoments(_ payload: MomentsPayload) async throws -> [Moment] {
        return try await secureAPI.task(payload: payload, fetchMomentsTask, decode: [Moment].self)
    }
}

// MARK: Private Methods -
private extension MomentAPI {
    
    private func uploadMomentTask(_ payload: UploadMomentPayload) async throws -> Result<Moment, HTTPStatus> {
        try await request.task(
            payload: payload,
            url: urlBuilder.momentURL(route: .upload, version: .v1),
            method: .post,
            to: Moment.self)
    }
    
    private func fetchMomentsTask(_ payload: MomentsPayload) async throws -> Result<[Moment], HTTPStatus> {
        try await request.task(
            payload: payload,
            url: urlBuilder.momentURL(route: .moments, version: .v1),
            method: .post,
            to: [Moment].self)
    }
}