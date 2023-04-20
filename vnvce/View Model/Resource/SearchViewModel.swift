
import SwiftUI
import VNVCECore

class SearchViewModel: ObservableObject {
    private let searchAPI = SearchAPI()
    private let pagination = PagingData(itemsPerPage: 40)
    
    @Published public var searchField: String = ""
    @Published public var searchText: String = ""
    
    @Published private(set) public var searchResults: PaginationResponse<User.Public> = .init()
    
    @Published public var scrollOffset: CGFloat = .zero
    
    @Published public var isRunning = false
    @Published public var isRunningNext = false
    
    @Published public var navigation = NavigationCoordinator()
    
    private var searchTask: Task<Void, Never>?
    
    @MainActor
    public func searchFirstPage(_ value: String) {
        searchTask?.cancel()
        if value.isEmpty {
            isRunning = false
            searchResults.items.removeAll()
        } else {
            searchTask = Task {
                isRunning = true
                await searchFirstPageTask(value)
                searchTask?.cancel()
                await MainActor.run {
                    isRunning = false
                }
            }
        }
    }
    
    @MainActor
    public func searchNextPage() {
        searchTask?.cancel()
        searchTask = Task {
            await loadNextPageTask()
            searchTask?.cancel()
        }
    }
    
    public func onChangeSearchField(_ value: String) {
        let trimmedText = value.trimmingCharacters(in: .whitespaces)
        searchText = trimmedText
        isRunning = !value.isEmpty
    }
    
    public func navigationController(_ controller: UINavigationController) {
        navigation.controller = controller
        controller.delegate = navigation
        controller.interactivePopGestureRecognizer?.delegate = navigation
        controller.interactivePopGestureRecognizer?.isEnabled = true
    }
}

extension SearchViewModel {
    func searchFirstPageTask(_ value: String) async {
        do {
            await pagination.reset()
            guard let result = try await pagination.loadNextPage ({ page in
                try await self.searchTask(value, page: page)
            }) else {
                return
            }
            
            await MainActor.run {
                self.searchResults.metadata = result.metadata
                self.searchResults.items = result.items
                print(result.items.count)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func loadNextPageTask() async {
        if searchResults.items.count < searchResults.metadata.total {
            do {
                try await Task.sleep(seconds: 0.5)
                guard let result = try await pagination.loadNextPage ({ page in
                    try await self.searchTask(self.searchText, page: page)
                }) else {
                    return
                }
                
                await MainActor.run {
                    self.searchResults.metadata = result.metadata
                    self.searchResults.items += result.items
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func searchTask(_ value: String, page: Int) async throws -> PaginationResponse<User.Public> {
        return try await searchAPI.searchUser(search: value, params: .init(page: page, per: 40))
    }
}
