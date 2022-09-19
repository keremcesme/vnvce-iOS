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

let postsPerPage: Int = 6

class PostsViewModel: ObservableObject {
    private let postAPI = PostAPI.shared
    
    private let imagePrefetcher: ImagePrefetcher
    private let scrollViewPrefetcher: ScrollViewPrefetcher
    
    @Published private(set) public var postResults: Pagination<Post> = Pagination()
    
    @Published private(set) public var prefetcherImageURLs: [URL] = []
    
    @Published public var isRunning = false
    
    private let pagingData = PagingData(itemsPerPage: postsPerPage)
    
    private var fetchTask: Task<Void, Never>?
    
    @Published public var selectedPost = SelectedPost()
    
    init() {
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
    public func tapPostAction(_ value: TappedPost) async {
        if !selectedPost.didAppear {
            selectedPost.rect = value.rect
            selectedPost.post = value.post
            selectedPost.previewImage = value.image
            selectedPost.didAppear = true
            try? await Task.sleep(seconds: 0.01)
            withAnimation(response: 0.25) {
                self.selectedPost.show = true
            } after: {
                self.selectedPost.ready = true
            }

        }
    }
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
                self.postResults.metadata = result.metadata
                self.postResults.items = result.items
            }
        } catch {
            if Task.isCancelled { return }
            print(error.localizedDescription)
        }
    }
    
    func loadNextPageTask() async {
        if Task.isCancelled { return }
        if postResults.items.count < postResults.metadata.total {
            do {
                try await Task.sleep(seconds: 0.5)
                guard let result = try await pagingData.loadNextPage(dataFetchProvider: fetch) else {
                    return
                }
                if Task.isCancelled { return }
                await MainActor.run {
                    self.postResults.metadata = result.metadata
                    self.postResults.items += result.items
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
        let result = try await postAPI.fetchPosts(params: params)
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
    
    typealias TappedPost = (post: Post, image: UIImage, rect: CGRect)
    
    struct SelectedPost: Equatable {
        var post: Post? = nil
        var previewImage: UIImage = UIImage()
        var rect: CGRect = .zero
        var didAppear: Bool = false
        var show: Bool = false
        var ready: Bool = false
    }
}
