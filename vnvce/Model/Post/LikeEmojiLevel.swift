//
//  LikeEmojiLevel.swift
//  vnvce
//
//  Created by Kerem Cesme on 7.10.2022.
//

import Foundation
import SwiftUI

enum LikeEmojiLevel: String {
    case level1 = "slightly-smiling-face"
    case level2 = "grinning-face-with-big-eyes"
    case level3 = "star-struck"
    case level4 = "smiling-face-with-smiling-eyes"
    case level5 = "melting-face"
    case level6 = "red-heart"
    case level7 = "heart-on-fire"
    
    var image: UIImage {
        return UIImage(named: self.rawValue)!
    }
}
