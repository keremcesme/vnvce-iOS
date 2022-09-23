//
//  PostMediaPayload.swift
//  vnvce
//
//  Created by Kerem Cesme on 13.09.2022.
//

import Foundation

struct PostMediaPayload: Encodable {
    let type: MediaType
    let name: String
    let ratio: Float
    let url: String
    let thumbnailURL: String?
    
    init(type: MediaType,
         name: String,
         ratio: Float,
         url: String,
         thumbnailURL: String? = nil
    ) {
        self.type = type
        self.name = name
        self.ratio = ratio
        self.url = url
        self.thumbnailURL = thumbnailURL
    }
}
