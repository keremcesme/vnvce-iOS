//
//  LibraryAsset.swift
//  vnvce
//
//  Created by Kerem Cesme on 23.08.2022.
//

import Foundation
import Photos

//fileprivate typealias FetchAssetsType = (assets: [LibraryAsset], thumbnail: UIImage?)

struct LibraryAsset: Identifiable, Hashable {
    var id = UUID().uuidString
    var asset: PHAsset
}
