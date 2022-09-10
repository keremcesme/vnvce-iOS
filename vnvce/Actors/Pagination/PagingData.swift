//
//  PagingData.swift
//  vnvce
//
//  Created by Kerem Cesme on 10.09.2022.
//

import Foundation

typealias PaginateArguments = (page: Int, per: Int)
typealias PaginationResult<T> = (items: [T], metadata: PageMetadata)

protocol PaginationProtocol {
    
    func loadFirstPageTask() async
    
    func loadNextPageTask() async
    
}

actor PagingData {
    private(set) var currentPage = 0
    private(set) var hasReachedEnd = false
    
    let itemsPerPage: Int
    
    init(itemsPerPage: Int){
        assert(itemsPerPage > 0, "Items per page must be greater than zero")
        self.itemsPerPage = itemsPerPage
    }
    
    var nextPage: Int {currentPage + 1}
    var shouldLoadNexPage: Bool {
        !hasReachedEnd
    }
    
    func loadNextPage<T>(
        dataFetchProvider: @escaping (Int) async throws -> PaginationResult<T>?
    ) async throws -> PaginationResult<T>? {
        
        if Task.isCancelled { return nil }
//        print("PAGING: Current Page \(currentPage), nextPage: \(nextPage)")
        
        guard shouldLoadNexPage else {
//            print("PAGING: Stop loading next page. Has Reached end: \(hasReachedEnd), next page: \(nextPage).")
            return nil
        }
        
        let nextPage = self.nextPage
        guard let result = try await dataFetchProvider(nextPage) else {
            return nil
        }
        
        if Task.isCancelled || nextPage != self.nextPage {
            return nil
        }
        
        currentPage = nextPage
        hasReachedEnd = result.items.count < itemsPerPage
        
//        print("PAGING: fetch \(result.items.count) items(s) successfully. Current page: \(currentPage)")
        
        return result
    }
    
    func reset() {
//        print("PAGING: RESET")
        currentPage = 0
        hasReachedEnd = false
    }
}
