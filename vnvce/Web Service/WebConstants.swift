//
//  WebConstants.swift
//  vnvce
//
//  Created by Kerem Cesme on 18.08.2022.
//

import Foundation

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
    static let apiVersion = APIVersions.v1
    static let url = "https://vnvce.com" // PROD
//    static let url = "https://1134-78-135-95-14.ngrok.io" // DEV
    
    static let storageURL = "gs://vnvce-" // FIREBASE STORAGE
    
    static let baseURL = "\(url)/api/\(apiVersion)/"
    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
}


enum HTTPMethods: String {
    case POST, GET, PUT, PATCH, DELETE
}

enum MIMEType {
    static let appJSON = "application/json"
    static let bearer = "Bearer "
}

//enum HTTPHeaders: String {
//    case contentType = "Content-Type"
//    case authorization = "Authorization"
//}

enum HTTPError: Error {
    case badURL, badResponse, errorDecodingData, invalidURL, badAccessTokenOrBadURL, badAccessToken
}
