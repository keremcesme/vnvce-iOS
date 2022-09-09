//
//  EditProfilePicturePayload.swift
//  vnvce
//
//  Created by Kerem Cesme on 23.08.2022.
//

import Foundation

struct EditProfilePicturePayload: Encodable {
    let url: String
    let name: String
    let alignment: ProfilePictureAlignmentType
}
