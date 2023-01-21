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
    
    init(result: T? = nil,
         message: String
    ) {
        self.result = result
        self.message = message
    }
}

struct Pagination<T: Decodable>: Decodable {
    var items: [T]
    var metadata: PageMetadata
    
    init(items: [T] = [],
         metadata: PageMetadata = PageMetadata(page: 0, per: 0, total: 0)) {
        self.items = items
        self.metadata = metadata
    }
}

typealias PaginationResponseOLD<T: Decodable> = Response<Pagination<T>>

//struct ResponseWithStatus<T: Decodable>: Decodable {
//    let response: Response<T>?
//    let status: HTTPStatus
//
//    init(
//        response: Response<T>? = nil,
//        status: HTTPStatus
//    ) {
//        self.response = response
//        self.status = status
//    }
//}
