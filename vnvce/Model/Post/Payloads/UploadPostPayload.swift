//
//  UploadPostPayload.swift
//  vnvce
//
//  Created by Kerem Cesme on 13.09.2022.
//

import Foundation

struct UploadPostPayload: Encodable {
    let description: String?
    let media: PostMediaPayload
    let type: PostType
    let coOwnerID: UUID?
    
    init(description: String? = nil,
         media: PostMediaPayload,
         type: PostType,
         coOwnerID: UUID? = nil
    ) {
        self.description = description
        self.media = media
        self.type = type
        self.coOwnerID = coOwnerID
    }
}
