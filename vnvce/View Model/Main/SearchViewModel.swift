//
//  SearchViewModel.swift
//  vnvce
//
//  Created by Kerem Cesme on 9.09.2022.
//

import Foundation

class SearchViewModel: ObservableObject {
    @Published public var show: Bool = false
    
    @Published public var searchField: String = ""
}
