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
