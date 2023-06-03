
import Foundation
import SwiftUI

enum ImageDownloadState: Equatable, Hashable {
    case nothing
    case downloading
    case downloaded(UIImage)
}
