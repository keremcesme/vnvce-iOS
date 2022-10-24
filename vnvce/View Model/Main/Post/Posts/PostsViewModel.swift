//
//  PostsViewModel.swift
//  vnvce
//
//  Created by Kerem Cesme on 19.09.2022.
//

import Foundation
import SwiftUI
import Nuke
import ScrollViewPrefetcher

let postsPerPage: Int = 14

class PostsViewModel: ObservableObject {
    private let postAPI = PostAPI.shared
    
    private let imagePrefetcher: ImagePrefetcher
    private let scrollViewPrefetcher: ScrollViewPrefetcher
    
    @Published private(set) public var payload: PostsPayload
    
    @Published public var postResults: Pagination<Post> = Pagination()
//    @Published public var postResults: Pagination<Post>?
    
    @Published private(set) public var prefetcherImageURLs: [URL] = []
    
    @Published public var isRunning = false
    
    private let pagingData = PagingData(itemsPerPage: postsPerPage)
    
    private var fetchTask: Task<Void, Never>?
    
    @Published public var scrollToPostID = UUID()
    @Published public var updateCurrentPostRectAfterScroll: Bool = false
    
    @Published public var selectedPost = SelectedPost()
    @Published public var currentPostIndex: Int = 0
    
    
    init(_ payload: PostsPayload = .me(archived: false)) {
        self.payload = payload
        self.imagePrefetcher = .init()
        self.scrollViewPrefetcher = .init()
        self.scrollViewPrefetcher.delegate = self
    }
    
    @MainActor
    @Sendable
    public func loadFirstPage() async {
        fetchTask?.cancel()
        fetchTask = Task {
            isRunning = true
            await loadFirstPageTask()
            if !Task.isCancelled {
                isRunning = false
                fetchTask = nil
            }
        }
    }
    
    @MainActor
    @Sendable
    public func loadNextPage() async {
        if fetchTask == nil {
            fetchTask = Task {
                isRunning = true
                await loadNextPageTask()
                if !Task.isCancelled {
                    isRunning = false
                    fetchTask = nil
                }
            }
        }
    }
    
    @MainActor
    @Sendable
    public func tapPostAction(_ value: SelectPost) async {
        if !selectedPost.didAppear {
            selectedPost.frame = value.frame
            selectedPost.size = value.size
            selectedPost.post = value.post
//            selectedPost.index = value.index
            selectedPost.previewImage = value.previewImage
            selectedPost.didAppear = true
            
//            if let index = postResults.items.firstIndex(where: {$0 == value.post}) {
//                currentPostIndex = index
//            }
            
//            selectedPostIndex = value.index
            
            
//            print("POST ORIGIN POSITION: \(value.rect.origin.height)")
//            let origin = value.rect.origin.height
//            print("POST TOP POSITION: \(origin - value.rect.size.height / 2)")
//            print("POST BOTTOM POSITION: \(value.rect.bottom.height)")
            
            try? await Task.sleep(seconds: 0.001)
            withAnimation(response: 0.25) {
                self.selectedPost.show = true
            } after: {
                self.selectedPost.ready = true
                self.scrollToPostID = value.post.id
            }

        }
    }
    
//    @MainActor
//    func updateCurrentPostRect(_ value: Bool, post: Post, rect: CGRect, image: UIImage) {
//        if value && scrollToPostID == post.id {
//            selectedPost.rect = rect
//            selectedPost.post = post
//            selectedPost.previewImage = image
//            updateCurrentPostRectAfterScroll = false
//        }
//    }
}

// MARK: FETCH
extension PostsViewModel: PaginationProtocol {
    func loadFirstPageTask() async {
        if Task.isCancelled { return }
        do {
            await pagingData.reset()
            guard let result = try await pagingData.loadNextPage(dataFetchProvider: fetch) else {
                return
            }
            if Task.isCancelled { return }
            await MainActor.run {
                self.postResults = result
//                self.postResults.metadata = result.metadata
//                self.postResults.items = result.items
            }
        } catch {
            if Task.isCancelled { return }
            print(error.localizedDescription)
        }
    }
    
    func loadNextPageTask() async {
        if Task.isCancelled { return }
//        guard var postResults = postResults else {
//            return
//        }
        if postResults.items.count < postResults.metadata.total {
            do {
                try await Task.sleep(seconds: 0.5)
                guard let result = try await pagingData.loadNextPage(dataFetchProvider: fetch) else {
                    return
                }
                if Task.isCancelled { return }
                postResults.metadata = result.metadata
                postResults.items += result.items
                let newResults = postResults
                await MainActor.run {
                    self.postResults = newResults
                }
            } catch {
                if Task.isCancelled { return }
                print(error.localizedDescription)
            }
        }
    }
    
    @Sendable
    private func fetch(page: Int) async throws -> Pagination<Post> {
        let params = PaginationParams(page: page, per: postsPerPage)
        let result = try await postAPI.fetchPosts(payload: payload, params: params)
        return result
    }
}

// MARK: Prefetch Post Images
extension PostsViewModel: ScrollViewPrefetcherDelegate {
    
    @Sendable
    public func onAppear(_ postID: UUID) {
        scrollViewPrefetcher.onAppear(postIndex(postID))
    }
    
    @Sendable
    public func onDisappear(_ postID: UUID) {
        scrollViewPrefetcher.onDisappear(postIndex(postID))
    }
    
    private func postIndex(_ postID: UUID) -> Int {
        for post in postResults.items.enumerated() where post.element.id == postID {
            return post.offset
        }
        return 0
    }
    
    func getAllIndicesForPrefetcher(_ prefetcher: ScrollViewPrefetcher) -> Range<Int> {
        prefetcherImageURLs.indices
    }
    
    func prefetcher(_ prefetcher: ScrollViewPrefetcher, prefetchItemsAt indices: [Int]) {
        imagePrefetcher.startPrefetching(with: indices.map { prefetcherImageURLs[$0] })
    }
    
    func prefetcher(_ prefetcher: ScrollViewPrefetcher, cancelPrefechingForItemAt indices: [Int]) {
        imagePrefetcher.stopPrefetching(with: indices.map { prefetcherImageURLs[$0] })
    }
    
    func resetPrefetcher() async {
        prefetcherImageURLs.removeAll()
    }
    
    
}

extension PostsViewModel {
    struct SelectPost {
        var post: Post
        var previewImage: UIImage
        var frame: CGRect
        var size: CGSize
//        var topFrame: CGFloat
//        var bottomFrame: CGFloat
    }
    
    struct SelectedPost: Equatable {
        var post: Post? = nil
        var previewImage: UIImage = UIImage()
        var frame: CGRect = .zero
        var size: CGSize = .zero
        var index: Int = 0
        
        var didAppear: Bool = false
        var show: Bool = false
        var ready: Bool = false
    }
}
