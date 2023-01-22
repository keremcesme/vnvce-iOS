//
//  SearchView.swift
//  vnvce
//
//  Created by Kerem Cesme on 10.11.2022.
//

import SwiftUI
import SwiftUIX
import PureSwiftUI
import Introspect
import Colorful

struct SearchViewOLD2: View {
    @Environment(\.dismiss) public var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    private let statusBarHeight = UIDevice.current.statusBarHeight()
    
    @EnvironmentObject public var currentUserVM: CurrentUserViewModelOLD
    @EnvironmentObject public var searchVM: SearchViewModelOLD
    @EnvironmentObject public var camera: CameraManager
    
    @StateObject public var navigationController = NavigationController()
    
    
    @State public var scrollOffset: CGFloat = 0
    @State public var isScrolling: Bool = false
    @State public var willDismiss: Bool = false
    
    @FocusState public var focused: Bool
    
    private func offsetTask(_ value: CGFloat) {
        if !willDismiss {
            self.scrollOffset = -(value - self.statusBarHeight)
            if scrollOffset > 0 {
                if !isScrolling {
                    UIDevice.current.setStatusBar(style: .lightContent, animation: true)
                    isScrolling = true
                }
            } else {
                if isScrolling {
                    UIDevice.current.setStatusBar(style: .default, animation: true)
                    isScrolling = false
                }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top){
                CurrentUserBackground()
                TopBackground
                ScrollView { ScrollViewBody }
                .onTapGesture {
                    hideKeyboard()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            .introspectNavigationController(customize: navigationController.properties)
        }
        .cornerRadius(UIDevice.current.screenCornerRadius, corners: [.topLeft, .topRight])
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    private var ScrollViewBody: some View {
        LazyVStack(spacing: 15, pinnedViews: .sectionHeaders) { LazyVStackView }
        .offsetY(offsetTask)
        .introspectScrollView { scrollView in
            scrollView.keyboardDismissMode = .interactive
        }
    }
    
    @ViewBuilder
    private var LazyVStackView: some View {
        Section { SectionView.padding(.horizontal, 15) } header: { SearchField }
    }
    
    @ViewBuilder
    private var SectionView: some View {
        let trimmedQueryValue = self.searchVM.searchField.trimmingCharacters(in: .whitespaces)
        if !trimmedQueryValue.isEmpty {
            SearchResults
            if searchVM.isRunning {
                RedactedResults
            }
        }
        SearchingMoreIndicator
    }
    
    @ViewBuilder
    private var SearchingMoreIndicator: some View {
        if searchVM.searchResults.items.count < searchVM.searchResults.metadata.total {
            ProgressView()
                .opacity(searchVM.isRunning ? 1 : 0.000001)
                .padding(.top, 15)
        }
    }
    
    @ViewBuilder
    private var TopBackground: some View {
        LinearGradient(colors: [.black.opacity(0.5), .clear], startPoint: .top, endPoint: .bottom)
            .frame(maxWidth: .infinity)
            .frame(height: self.statusBarHeight + 70)
            .opacity(scrollOffset / 10)
            .ignoresSafeArea()
    }
}
