//
//  JSONCoding+Helpers.swift
//  vnvce
//
//  Created by Kerem Cesme on 18.08.2022.
//

import Foundation

fileprivate struct JSONHelper {
    static let shared = JSONHelper()
    
    private init() {}
    
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    // - MARK: JSON Decoder -
    public func responseDecoder<T: Decodable>(
        _ from: T.Type,
        data: Data
    ) throws -> T {
        let apiResponse = try jsonDecoder.decode(T.self, from: data)
        
        return apiResponse
    }
    
    // - MARK: JSON Encoder -
    public func payloadEncoder<T: Encodable>(
        _ payload: T
    ) throws -> Data {
        return try jsonEncoder.encode(payload)
    }
}

extension Data {
    func decode<T: Decodable>(_ from: T.Type) throws -> T {
        return try JSONHelper.shared.responseDecoder(from, data: self)
    }
    
    var json: String? {
//        let json = String(data: self, encoding: .utf8)
        let str = String(decoding: self, as: UTF8.self)
        return str
    }
    
}

extension Encodable {
    func encode() throws -> Data {
        return try JSONHelper.shared.payloadEncoder(self)
    }
}
