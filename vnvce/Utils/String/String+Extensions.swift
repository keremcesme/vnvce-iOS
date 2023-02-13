
import Foundation

extension String {

    var length: Int {
        return count
    }

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
    
    enum StorageMediaType: String {
        case image = "image"
        case movie = "movie"
        
        var `extension`: String {
            switch self {
            case .image:
                return "jpg"
            case .movie:
                return "mp4"
            }
        }
    }
    
    func convertStorageName(_ type: StorageMediaType = .image) -> String {
        return "\(type.rawValue)-\(self).\(type.extension)"
    }
}
