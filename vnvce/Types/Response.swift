//
//  Response.swift
//  vnvce
//
//  Created by Kerem Cesme on 18.08.2022.
//

import Foundation

struct Response<T: Decodable>: Decodable {
    var result: T?
    var message: String
    
    init(
        result: T? = nil,
        message: String
    ) {
        self.result = result
        self.message = message
    }
}

struct ResponseWithStatus<T: Decodable>: Decodable {
    let response: Response<T>?
    let status: HTTPStatus
    
    init(
        response: Response<T>? = nil,
        status: HTTPStatus
    ) {
        self.response = response
        self.status = status
    }
}
