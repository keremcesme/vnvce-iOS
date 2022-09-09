//
//  LibraryAlbum.swift
//  vnvce
//
//  Created by Kerem Cesme on 23.08.2022.
//

import Foundation
import Photos
import UIKit

struct LibraryAlbum: Identifiable, Hashable {
    var id = UUID().uuidString
    
    var title: String
    var count: Int
    var thumbnail: UIImage
    var collection: PHAssetCollection
}
