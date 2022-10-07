//
//  PostAPI.swift
//  vnvce
//
//  Created by Kerem Cesme on 13.09.2022.
//

import Foundation

struct PostAPI {
    static let shared = PostAPI()
    
    private init() {}
    
    public let urlBuilder = URLBuilder.shared
    public let request = AFRequest.shared
    public let secureAPI = SecureAPI.shared
}

// MARK: Public Methods -
extension PostAPI {
    
    public func uploadPost(payload: UploadPostPayload) async throws -> Post {
        return try await secureAPI.task(payload: payload, uploadPostTask, decode: Post.self)
    }
    
    public func fetchPosts(payload: PostsPayload, params: PaginationParams) async throws -> Pagination<Post> {
        return try await secureAPI.task(payload: payload, pagination: params, fetchPostsTask, decode: Pagination<Post>.self)
    }
    
    public func setPostDisplayTime(payload: PostDisplayTimePayload) async throws -> Post.DisplayTime {
        return try await secureAPI.task(payload: payload, setPostDisplayTimeTask, decode: Post.DisplayTime.self)
    }
    
}

// MARK: Private Methods -
private extension PostAPI {
    
    private func uploadPostTask(_ payload: UploadPostPayload) async throws -> Result<Post, HTTPStatus> {
        try await request.task(
            payload: payload,
            url: urlBuilder.postURL(route: .upload, version: .v1),
            method: .post,
            to: Post.self)
    }
    
    private func fetchPostsTask(_ payload: PostsPayload, _ params: PaginationParams) async throws -> Result<Pagination<Post>, HTTPStatus> {
        try await request.paginationTask(
            payload: payload,
            url: urlBuilder.postURL(route: .posts(params), version: .v1),
            method: .post,
            to: Post.self)
    }
    
    private func setPostDisplayTimeTask(_ payload: PostDisplayTimePayload) async throws -> Result<Post.DisplayTime, HTTPStatus> {
        try await request.task(
            payload: payload,
            url: urlBuilder.postURL(route: .upload, version: .v1),
            method: .post,
            to: Post.DisplayTime.self)
    }
}
