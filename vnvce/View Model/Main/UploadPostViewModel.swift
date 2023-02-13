//
//  UploadPostViewModel.swift
//  vnvce
//
//  Created by Kerem Cesme on 13.09.2022.
//

import Foundation
import UIKit

class UploadPostViewModel: ObservableObject {
    private let postAPI = PostAPI.shared
    private let storageAPI = StorageAPIOLD.shared
    
    @Published public var showUploadPostView: Bool = false
    @Published public var showOutputView: Bool = false
    
    @Published public var selectedImage = UIImage()
    
    @Published var uploading = false
    @Published var progress: Double = 0
    
}

extension UploadPostViewModel {
    @MainActor
    public func uploadPost() async {
        if Task.isCancelled { return }
        
        self.progress = 0
        self.uploading = true
        
        do {
            
            let media = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<PostMediaPayload, Error>) in
                do {
                    try uploadPostToStorage { media in
                        continuation.resume(returning: media)
                    }
                } catch {
                    continuation.resume(throwing: error)
                }
            }
            if Task.isCancelled { return }
            let post = try await self.uploadPostToServer(media: media)
            if Task.isCancelled { return }
            print("✅ [STEP: 2] ~ Post is uploaded to Server.")
            print(post)
        } catch {
            print(error.localizedDescription)
            return
        }
        
    }
}

private extension UploadPostViewModel {
    
    private func uploadPostToStorage(completion: @escaping (PostMediaPayload) -> Void) throws {
        try storageAPI.uploadImagePost(self.selectedImage) { status, progress in
            switch status {
            case .uploading:
                self.progress = progress
            case let .success(postMediaPayload):
                print("✅ [STEP: 1] ~ Post is uploaded to Firebase Storage.")
                return completion(postMediaPayload)
            }
        }
    }
    
    private func uploadPostToServer(media: PostMediaPayload) async throws -> Post {
        let payload = UploadPostPayload(media: media, type: .single)
        return try await postAPI.uploadPost(payload: payload)
    }
    
}
