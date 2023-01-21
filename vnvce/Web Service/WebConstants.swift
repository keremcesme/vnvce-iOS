
import Foundation
import VNVCECore
import UIKit

enum APIVersions {
    static let v1 = "v1"
    static let v2 = "v2"
    static let v3 = "v3"
    static let v4 = "v4"
}

enum APIVersion: String {
    case v1 = "v1"
    case v2 = "v2"
    case v3 = "v3"
    case v4 = "v4"
}

enum WebConstants {
    // MARK: Dev Variables
    static let url = "88f4-78-135-94-156.ngrok.io"
    static let run: RunMode = .prod
    
    static let storageURL = "gs://vnvce-" // FIREBASE STORAGE
    
    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
}

enum MIMEType {
    static let appJSON = "application/json"
    static let bearer = "Bearer "
}

enum HTTPError: Error {
    case badURL, badResponse, errorDecodingData, invalidURL, badAccessTokenOrBadURL, badAccessToken
}
