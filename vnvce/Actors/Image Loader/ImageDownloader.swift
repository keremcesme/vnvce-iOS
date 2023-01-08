//
//  ImageDownloader.swift
//  vnvce
//
//  Created by Kerem Cesme on 14.11.2022.
//

import SwiftUI
import Cache


actor ImageDownloader {
    
    private let diskConfig = DiskConfig(name: "Moment",
                                        maxSize: 1_073_741_824,
                                        protectionType: .complete)
    
    private let memoryConfig = MemoryConfig(expiry: .seconds(86400))
    private let transformer = TransformerFactory.forData()
    
    public func load(url: URL) async throws -> UIImage {
        let storage: Storage<String, Data> = try Storage(
            diskConfig: diskConfig,
            memoryConfig: memoryConfig,
            transformer: transformer
        )
        
        let data: Data = try await {
            if let data = try loadFromCache(url, storage: storage) {
                return data
            } else {
                return try await download(url, storage: storage)
            }
        }()
        
        return UIImage(data: data)!
    }
    
    private func loadFromCache(_ url: URL, storage: Storage<String, Data>) throws -> Data? {
        guard try storage.existsObject(forKey: url.absoluteString) else {
            return nil
        }
        
        return try storage.object(forKey: url.absoluteString)
    }
    
    private func download(_ url: URL, storage: Storage<String, Data>) async throws -> Data {
        let request = URLRequest(url: url)
        
        let response = try await URLSession.shared.data(for: request)
        
        let data = response.0
        
        try storage.setObject(data, forKey: url.absoluteString)
        
        return data
    }
    
    
    
}
