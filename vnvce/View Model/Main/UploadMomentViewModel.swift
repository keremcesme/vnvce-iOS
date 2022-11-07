//
//  UploadMomentViewModel.swift
//  vnvce
//
//  Created by Kerem Cesme on 24.10.2022.
//

import Foundation
import UIKit

class UploadMomentViewModel: ObservableObject {
    private let momentAPI = MomentAPI.shared
    private let storageAPI = StorageAPI.shared
    
    @Published var uploading = false
    @Published var progress: Double = 0
    
}

extension UploadMomentViewModel {
    
    public func uploadMoment(image: UIImage) {
        self.progress = 0
        self.uploading = true
        
        do {
            try uploadMomentToStorage(image: image) { payload in
                Task {
                    let moment = try await self.uploadMomentToServer(payload: payload)
                    await MainActor.run {
                        print("✅ [STEP: 2] ~ Moment is uploaded to Server.")
                        print(moment)
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func uploadMoment(image: UIImage) async {
        if Task.isCancelled { return }
        
        await MainActor.run {
            self.progress = 0
            self.uploading = true
        }
        
        do {
            let payload = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<UploadMomentPayload, Error>) in
                do {
                    try uploadMomentToStorage(image: image) { payload in
                        continuation.resume(returning: payload)
                    }
                } catch {
                    continuation.resume(throwing: error)
                }
            }
            
            if Task.isCancelled { return }
            let moment = try await self.uploadMomentToServer(payload: payload)
            if Task.isCancelled { return }
            await MainActor.run {
                print("✅ [STEP: 2] ~ Moment is uploaded to Server.")
                print(moment)
            }
        } catch {
            print(error.localizedDescription)
            return
        }
    }
    
}

private extension UploadMomentViewModel {
    
    private func uploadMomentToStorage(image: UIImage, completion: @escaping (UploadMomentPayload) -> Void) throws {
        
        try storageAPI.uploadImageMoment(image) { status, progress in
            switch status {
            case .uploading:
                DispatchQueue.main.async {
                    self.progress = progress
                }
            case let .success(payload):
                print("✅ [STEP: 1] ~ Moment is uploaded to Firebase Storage.")
                return completion(payload)
            }
//            switch status {
//            case .uploading:
//                self.progress = progress
//            case let .success(payload):
//                print("✅ [STEP: 1] ~ Post is uploaded to Firebase Storage.")
//                return completion(payload)
//            }
        }
    }
    
    private func uploadMomentToServer(payload: UploadMomentPayload) async throws -> Moment {
        return try await momentAPI.uploadMoment(payload)
    }
    
}
