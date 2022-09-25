//
//  PostViewModel.swift
//  vnvce
//
//  Created by Kerem Cesme on 23.09.2022.
//

import SwiftUI

typealias DismissPostViewAction = () -> Void

class PostViewModel: NSObject, ObservableObject {
    
    // MARK: Timer
    public var timer: Timer = Timer()
    
    @Published public var totalSeconds: CGFloat = 0
    
    @Published public var secondsElapsed: CGFloat = 0
    @Published public var maxDuration: CGFloat = 5.1
    
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
}


