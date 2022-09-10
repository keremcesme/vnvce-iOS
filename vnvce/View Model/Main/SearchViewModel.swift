//
//  SearchViewModel.swift
//  vnvce
//
//  Created by Kerem Cesme on 9.09.2022.
//

import Foundation

class SearchViewModel: ObservableObject {
    private let searchAPI = SearchAPI.shared
    
    @Published public var show: Bool = false
    
    @Published public var searchField: String = ""
    

    @Published public var searchResults = [User.Public]()
    @Published private(set) var metadata = PageMetadata(page: 0, per: 40, total: 0)
    
    @Published public var isRunning = false
    
    private let pagingData = PagingData(itemsPerPage: 40)
    
    private var searchTask: Task<Void, Never>?
    
    @MainActor
    @Sendable
    public func loadFirstPage() async {
        searchTask?.cancel()
        let currentSearchField = searchField.trimmingCharacters(in: .whitespaces)
        if currentSearchField.isEmpty {
            isRunning = false
            searchResults.removeAll()
        } else {
            searchTask = Task {
                isRunning = true
                await loadFirstPageTask()
                if !Task.isCancelled {
                    isRunning = false
                }
            }
        }
    }
    
    @MainActor
    @Sendable
    public func loadNextPage() async {
        await loadNextPageTask()
    }
    
}

extension SearchViewModel: PaginationProtocol {
    
    func loadFirstPageTask() async {
        if Task.isCancelled { return }
        do {
            await pagingData.reset()
            guard let result = try await pagingData.loadNextPage(dataFetchProvider: search) else {
                return
            }
            if Task.isCancelled { return }
            DispatchQueue.main.async {
                self.metadata = result.metadata
                self.searchResults = result.items
            }
        } catch {
            if Task.isCancelled { return }
            print(error.localizedDescription)
        }
    }
    
    func loadNextPageTask() async {
        if Task.isCancelled { return }
        if searchResults.count < metadata.total {
            do {
                try await Task.sleep(seconds: 0.5)
                guard let result = try await pagingData.loadNextPage(dataFetchProvider: search) else {
                    return
                }
                if Task.isCancelled { return }
                
                DispatchQueue.main.async {
                    self.metadata = result.metadata
                    self.searchResults += result.items
                }
            } catch {
                if Task.isCancelled { return }
                print(error.localizedDescription)
            }
        }
        
        
    }
    
    @Sendable
    private func search(page: Int) async throws-> PaginationResult<User.Public>? {
        guard let result = try await searchAPI.searchUser(searchField, page: page, per: 40) else {
            return nil
        }
        if Task.isCancelled { return nil}
        return result
    }
}
