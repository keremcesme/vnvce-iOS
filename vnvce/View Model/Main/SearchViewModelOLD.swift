//
//  SearchViewModel.swift
//  vnvce
//
//  Created by Kerem Cesme on 9.09.2022.
//

import Foundation
import UIKit

class SearchViewModelOLD: ObservableObject {
    private let searchAPI = SearchAPIOLD.shared
    
    @Published public var show: Bool = false
    
    @Published public var searchField: String = ""
    @Published public var searchTerm: String = ""
    
    @Published private(set) public var searchResults: Pagination<User.PublicOLD> = Pagination()
    
    @Published public var isRunning = false
    
    private let pagingData = PagingData(itemsPerPage: 40)
    
    private var searchTask: Task<Void, Never>?
    
    init() {
//        self.pullToDismiss = PDPullToDismiss(scrollView: scrollView)
    }
    
    @MainActor
    @Sendable
    public func loadFirstPage() async {
        searchTask?.cancel()
        let currentSearchField = searchField.trimmingCharacters(in: .whitespaces)
        if currentSearchField.isEmpty {
            isRunning = false
            searchResults.items.removeAll()
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

extension SearchViewModelOLD: PaginationProtocol {
    
    func loadFirstPageTask() async {
        return
//        if Task.isCancelled { return }
//        do {
//            await pagingData.reset()
//            guard let result = try await pagingData.loadNextPage(dataFetchProvider: search) else {
//                return
//            }
//            if Task.isCancelled { return }
//            await MainActor.run {
//                self.searchResults.metadata = result.metadata
//                self.searchResults.items = result.items
//            }
//
//        } catch {
//            if Task.isCancelled { return }
//            print(error.localizedDescription)
//        }
    }
    
    func loadNextPageTask() async {
        return
//        if Task.isCancelled { return }
//        if searchResults.items.count < searchResults.metadata.total {
//            do {
//                try await Task.sleep(seconds: 0.5)
//                guard let result = try await pagingData.loadNextPage(dataFetchProvider: search) else {
//                    return
//                }
//                if Task.isCancelled { return }
//                self.searchResults.metadata = result.metadata
//                self.searchResults.items += result.items
//            } catch {
//                if Task.isCancelled { return }
//                print(error.localizedDescription)
//            }
//        }
//
//
    }
    
    @Sendable
    private func search(page: Int) async throws -> Pagination<User.PublicOLD> {
        let result = try await searchAPI.searchUser(searchTerm, page: page, per: 40)
        return result
    }
}