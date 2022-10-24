//
//  PostViewModel.swift
//  vnvce
//
//  Created by Kerem Cesme on 23.09.2022.
//

import SwiftUI

typealias DismissPostViewAction = () -> Void

class PostViewModel: NSObject, ObservableObject {
    
    private let postAPI = PostAPI.shared
    
    // MARK: Timer
    @Published public var timer: Timer?
    
    @Published public var totalSeconds: CGFloat = 0
    
    @Published public var secondsElapsed: CGFloat = 0
    @Published public var maxDuration: CGFloat = 3
    
    @Published public var timerIsRunning = false

    @Published public var stop: Bool = false
    
    // MARK: ScrollView, Refresh and Gesture Properties
    @Published public var scrollView: UIScrollView!
    
    @Published public var isEligible: Bool = false
    @Published public var isRefreshing: Bool = false
    
    @Published public var scrollOffset: CGPoint = .zero
    @Published public var scrollStartOffset: CGFloat = 0
    
    @Published public var isScrollEnabled: Bool = true
    
    @Published public var contentOffset: CGFloat = 0
    @Published public var progress: CGFloat = 0
    
    @Published public var offset: CGSize = .zero
    
    @Published public var onDragging: Bool = false
    
    public var dismiss: DismissPostViewAction?
    
    @Published private(set) var setDisplayTimeIsRunning = false
}

extension PostViewModel {
    
    public func setPostTimeTask(_ payload: PostDisplayTimePayload) async throws -> Post.DisplayTime {
        guard let result = await setPostDisplayTimeTask(payload) else {
            throw NSError(domain: "Error: Set Post Display Time ", code: 1)
        }
        setDisplayTimeIsRunning = false
        return result
    }
    
    private func setPostDisplayTimeTask(_ payload: PostDisplayTimePayload) async -> Post.DisplayTime? {
        if Task.isCancelled { return nil }
        if !setDisplayTimeIsRunning {
            setDisplayTimeIsRunning = true
            do {
                let result = try await postAPI.setPostDisplayTime(payload: payload)
                if Task.isCancelled { return nil }
                return result
            } catch {
                if Task.isCancelled { return nil }
                print(error.localizedDescription)
                return nil
            }
        } else {
            return nil
        }
        
    }
}
