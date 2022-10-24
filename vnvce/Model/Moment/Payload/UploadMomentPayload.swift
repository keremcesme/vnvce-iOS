//
//  UploadMomentPayload.swift
//  vnvce
//
//  Created by Kerem Cesme on 24.10.2022.
//

import Foundation

struct UploadMomentPayload: Encodable {
    let type: MediaType
    let name: String
    let url: String
    let thumbnailURL: String?
    
    init(type: MediaType,
         name: String,
         url: String,
         thumbnailURL: String? = nil
    ) {
        self.type = type
        self.name = name
        self.url = url
        self.thumbnailURL = thumbnailURL
    }
}
