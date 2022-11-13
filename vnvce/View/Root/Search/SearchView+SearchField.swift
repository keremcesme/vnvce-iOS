//
//  SearchView+SearchField.swift
//  vnvce
//
//  Created by Kerem Cesme on 11.11.2022.
//

import SwiftUI
import SwiftUIX
import PureSwiftUI

extension SearchView {
    
    private func dismissTask() {
        willDismiss = true
        UIDevice.current.setStatusBar(style: .lightContent, animation: true)
        withAnimation(response: 0.25) {
            searchVM.show = false
        }
        dismiss()
        camera.startSession()
    }
    
    private func onChangeSearchTerm(_ value: String) {
        searchVM.searchTerm = value
        if value.isEmpty {
            searchVM.isRunning = false
        } else {
            searchVM.isRunning = true
        }
    }
    
    @ViewBuilder
    public var SearchField: some View {
        HStack(spacing: 15) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(searchVM.searchField.isEmpty ? .secondary : .primary)
                    .font(.system(size: 18, weight: .medium, design: .default))
                    .frame(width: 18, height: 18, alignment: .center)
                
                TextField("Search", text: $searchVM.searchField)
                    .submitLabel(.search)
                    .focused($focused)
                    .accentColor(.blue)
                    .disableAutocorrection(true)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
            }
            .padding(.horizontal, 15)
            .background(SearchFieldBackground)
            .contentShape(Rectangle())
            .onPress {
                focused = true
            }
            .overlay(LoadingIndicator, alignment: .trailing)
            
            Button(action: dismissTask, label: CancelButton)
                .buttonStyle(.plain)
            
        }
        .padding(.horizontal, 15)
        .padding(.top, 5)
        .onChange(of: searchVM.searchField, perform: onChangeSearchTerm)
        .onReceive(searchVM.$searchTerm.debounce(for: 0.5, scheduler: RunLoop.main)) { _ in
            Task(operation: searchVM.loadFirstPage)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                focused = true
            }
        }
    }
    
    @ViewBuilder
    private var SearchFieldBackground: some View {
        Group {
            ZStack {
                Color.primary
                    .opacity(min(1.0 - scrollOffset / 10, 0.1))
                BlurView(style: .systemMaterial)
                    .opacity(scrollOffset / 10)
            }
        }
        .cornerRadius(12, style: .continuous)
    }
    
    @ViewBuilder
    private var CancelButton: some View {
        let title: String = "Cancel"
        Group {
            if colorScheme == .light {
                ZStack {
                    Text(title)
                        .foregroundColor(.primary)
                        .opacity(1.0 - scrollOffset / 10)
                    Text(title)
                        .foregroundColor(.white)
                        .opacity(scrollOffset / 10)
                }
            } else {
                Text(title)
                    .foregroundColor(.primary)
            }
        }
        .font(.system(size: 16, weight: .semibold, design: .default))
    }
    
    @ViewBuilder
    private var LoadingIndicator: some View {
        Group {
            if searchVM.isRunning {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.secondary)
                    .padding(.trailing, 15)
            } else {
                if !searchVM.searchField.isEmpty {
                    Button {
                        searchVM.searchField = ""
                    } label: {
                        ZStack {
                            Color.black.opacity(0.00001)
                                .frame(width: 50, height: 50)
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                                .font(.system(size: 18, weight: .medium, design: .default))
                                .frame(width: 18, height: 18, alignment: .center)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
