//
//  PageMetadata.swift
//  vnvce
//
//  Created by Kerem Cesme on 10.09.2022.
//

import Foundation

struct PageMetadata: Codable, Hashable {
    var page, per, total: Int
}

struct PaginationParams {
    let page: Int
    let per: Int
    
    var raw: String {
        return "?page=\(page)&per=\(per)"
    }
}
