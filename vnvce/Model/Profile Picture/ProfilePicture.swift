//
//  ProfilePicture.swift
//  vnvce
//
//  Created by Kerem Cesme on 7.09.2022.
//

import Foundation

struct ProfilePicture: Codable, Equatable, Hashable {
    let alignment: ProfilePictureAlignmentType
    let url: String
    let name: String
}
