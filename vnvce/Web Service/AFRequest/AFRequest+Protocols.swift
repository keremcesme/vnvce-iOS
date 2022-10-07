//
//  AFRequest+Protocols.swift
//  vnvce
//
//  Created by Kerem Cesme on 7.10.2022.
//

import Foundation
import Alamofire
import NIOCore

protocol AFRequestTaskProtocol {
    func task<T: Decodable, E: Encodable>(
        payload: E,
        url: URL,
        method: HTTPMethod,
        authorization: Bool,
        to: T.Type
    ) async throws -> Result<T, HTTPStatus>
    
    func paginationTask<T: Decodable, E: Encodable>(
        payload: E,
        url: URL,
        method: HTTPMethod,
        authorization: Bool,
        to: T.Type
    ) async throws -> Result<Pagination<T>, HTTPStatus>
}

protocol AFRequestDataTaskProtocol {
    func generateDataTask<T: Decodable, E: Encodable>(
        payload: E?,
        url: URL,
        method: HTTPMethod,
        authorization: Bool,
        to: T.Type
    ) throws -> DataTask<Response<T>>
    
    func generatePaginationDataTask<T: Decodable, E: Encodable>(
        payload: E?,
        url: URL,
        method: HTTPMethod,
        authorization: Bool,
        to: T.Type
    ) throws -> DataTask<PaginationResponse<T>>
}

protocol AFRequestResponseProtocol {
    func responseTask<T: Decodable>(
        dataTask: DataTask<Response<T>>
    ) async throws -> Result<T, HTTPStatus>
    
    func paginationResponseTask<T: Decodable>(
        dataTask: DataTask<PaginationResponse<T>>
    ) async throws -> Result<Pagination<T>, HTTPStatus>
}
