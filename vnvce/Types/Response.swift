//
//  Response.swift
//  vnvce
//
//  Created by Kerem Cesme on 18.08.2022.
//

import Foundation

struct Response<T: Decodable>: Decodable {
    var result: T
    var message: String
    var code: HTTPStatus
    
    init(
        result: T,
        message: String,
        code: HTTPStatus
    ) {
        self.result = result
        self.message = message
        self.code = code
    }
}
