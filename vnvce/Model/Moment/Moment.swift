//
//  Moment'.swift
//  vnvce
//
//  Created by Kerem Cesme on 24.10.2022.
//

import Foundation
import SwiftUI
import PureSwiftUIDesign

struct MomentDay: Decodable, Hashable {
    let id: UUID
    
    let day: Int
    let month: Month
    let year: Int
    
    var moments: [Moment]
//
    let createdAt: TimeInterval
    let modifiedAt: TimeInterval
}

struct Moment: Decodable, Hashable {
    let id: UUID
    let owner:  User.Public
    let media: MomentMedia
    
    let createdAt: TimeInterval
}

struct MomentMedia: Decodable, Hashable {
    let mediaType: MediaType
    let sensitiveContent: Bool
    let name: String
    let url: String
    let thumbnailURL: String?
}
