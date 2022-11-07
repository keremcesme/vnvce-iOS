//
//  SearchView.swift
//  vnvce
//
//  Created by Kerem Cesme on 9.09.2022.
//

import SwiftUI
import SwiftUIX
import Nuke
import NukeUI

struct SearchView: View {
    @EnvironmentObject private var currentUserVM: CurrentUserViewModel
    @EnvironmentObject private var keyboardController: KeyboardController
    @EnvironmentObject private var navigationController: NavigationController
    @EnvironmentObject private var searchVM: SearchViewModel
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack {
            EmptyView()
            if searchVM.show {
                Color.black.opacity(0.2).transition(.opacity)
            }
            Root
        }
        .animation(.spring(response: 0.3, dampingFraction: 1, blendDuration: 0), value: searchVM.show)
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    private var Root: some View {
        ZStack {
            if searchVM.show {
                BlurView(style: .regular)
                    .cornerRadius(UIDevice.current.screenCornerRadius, style: .continuous)
                    .onTapGesture(perform: hideKeyboard)
                    .transition(.move(edge: .bottom))
            }
            
            VStack(spacing: 10){
                if searchVM.show {
                    SearchField
                }
                if searchVM.show {
                    SearchBody
                        .transition(.move(edge: .bottom))
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        
    }
    
    @ViewBuilder
    private var SearchBody: some View {
        let trimmedQueryValue = self.searchVM.searchField.trimmingCharacters(in: .whitespaces)
        VStack(spacing:0) {
            Divider()
            ScrollView {
                VStack {
                    LazyVStack {
                        if !trimmedQueryValue.isEmpty {
                            ForEach(searchVM.searchResults.items, id: \.id) { user in
                                if user == searchVM.searchResults.items.last {
                                    UserCell(user)
                                        .task(searchVM.loadNextPage)
                                } else {
                                    UserCell(user)
                                }
                            }
                            if searchVM.isRunning {
                                RedactedResults
                            }
                        }
                    }
                    if searchVM.searchResults.items.count < searchVM.searchResults.metadata.total {
                        ProgressView()
                            .opacity(searchVM.isRunning ? 1 : 0.000001)
                            .padding(.top, 15)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 10)
                .padding(.bottom, bottomPadding)
            }
            .padding(.bottom, keyboardController.keyboardHeight)
            .onTapGesture(perform: hideKeyboard)
        }
    }
    
    private var bottomPadding: CGFloat {
        if keyboardController.keyboardHeight != 0 {
            return 15
        } else {
            return UIDevice.current.bottomSafeAreaHeight()
        }
    }
    
    @ViewBuilder
    private func UserCell(_ user: User.Public) -> some View {
        NavigationLink {
            UserProfileView(user: user)
                .environmentObject(currentUserVM)
                .environmentObject(navigationController)
        } label: {
            HStack(spacing: 10) {
                if let profilepicture = user.profilePicture {
                    LazyImage(url: URL(string: profilepicture.url)) { state in
                        if let uiImage = state.imageContainer?.image {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 50, alignment: .center)
                                .cornerRadius(10, style: .continuous)
                        }
                    }
                    .pipeline(.shared)
                    .processors([ImageProcessors.Resize(width: 50)])
                    .priority(.normal)
                }
                VStack(alignment: .leading) {
                    Text(user.displayName ?? "")
                        .font(.system(size: 16, weight: .semibold, design: .default))
                        .foregroundColor(.primary)
                    Text(user.username)
                        .font(.system(size: 14, weight: .regular, design: .default))
                        .foregroundColor(.secondary)
                }
                .foregroundColor(Color.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(Color(.systemGray2))
                    .font(.system(size: 11, weight: .semibold, design: .default))
            }
            .padding(10)
            .background{
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .foregroundColor(.primary)
                    .opacity(0.05)
            }
        }.isDetailLink(false)
    }
    
    @ViewBuilder
    private var RedactedResults: some View {
        ForEach((1...15).reversed(), id: \.self) {_ in
            HStack(spacing:10){
                RoundedRectangle(cornerRadius: 7.5)
                    .foregroundColor(Color.primary)
                    .frame(width: 50, height: 50, alignment: .center)
                VStack(alignment:.leading){
                    VStack(alignment: .leading){
                        Capsule()
                            .frame(width: 175, height:5 , alignment: .center)
                        Capsule()
                            .frame(width: 100, height: 5, alignment: .center)
                    }
                    .foregroundColor(Color.primary)
                }
                Spacer()
            }
            .opacity(0.1)
            .padding(10)
            .background({
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .foregroundColor(.primary)
                    .opacity(0.05)
            })
            .onTapGesture {
                self.hideKeyboard()
            }
        }
        .shimmering()
    }
}

extension SearchView {
 
    @ViewBuilder
    private var SearchField: some View {
        HStack(spacing: 18) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(searchVM.searchField.isEmpty ? .secondary : .primary)
                    .font(.system(size: 18, weight: .medium, design: .default))
                    .frame(width: 18, height: 18, alignment: .center)
                
                TextField("Search", text: $searchVM.searchField)
                    .submitLabel(.search)
                    .focused($isFocused)
                    .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: 50, alignment: .center)
                    .accentColor(.blue)
                    .disableAutocorrection(true)
                    .onSubmit {
//                        Task(operation: searchVM.loadFirstPage)
                    }
            }
            .padding(.horizontal, 15)
            .background(SearchFieldBackground)
            .textFieldFocusableArea()
            .overlay(alignment: .trailing) {
                if searchVM.isRunning {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.secondary))
                        .padding(.trailing, 15)
                } else {
                    if !searchVM.searchField.isEmpty {
                        Button {
                            searchVM.searchField = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                                .font(.system(size: 18, weight: .medium, design: .default))
                                .frame(width: 18, height: 18, alignment: .center)
                                .padding(.trailing, 15)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            Button {
                DispatchQueue.main.async {
                    isFocused = false
                    searchVM.show = false
                }
            } label: {
                Text("Cancel")
                    .foregroundColor(.primary)
                    .font(.system(size: 16, weight: .semibold, design: .default))
                    .padding(.trailing, 18)
                    .frame(maxHeight: 50)
            }.buttonStyle(.plain)
        }
        .padding(.leading, 18)
        .transition(.scale.combined(with: .opacity))
        .padding(.top, UIDevice.current.statusBarHeight())
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.31) {
                isFocused = true
            }
        }
        .onChange(of: searchVM.searchField) {
            searchVM.searchTerm = $0
            if $0.isEmpty {
                searchVM.isRunning = false
            } else {
                searchVM.isRunning = true
            }
        }
        .onReceive(searchVM.$searchTerm.debounce(for: 0.5, scheduler: RunLoop.main)) { _ in
            Task(operation: searchVM.loadFirstPage)
        }
    }
    
    @ViewBuilder
    private var SearchFieldBackground: some View {
        Color.primary
            .cornerRadius(12, style: .continuous)
            .opacity(0.1)
    }
}
