//
//  SearchView.swift
//  vnvce
//
//  Created by Kerem Cesme on 9.09.2022.
//

import SwiftUI
import SwiftUIX

struct SearchView: View {
    @EnvironmentObject private var keybaordController: KeyboardController
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
        ZStack(alignment: .top){
            if searchVM.show {
                SearchBody.transition(.move(edge: .bottom))
            }
            if searchVM.show {
                SearchField
            }
        }
    }
    
    @ViewBuilder
    private var SearchBody: some View {
        ZStack {
            BlurView(style: .regular)
                .cornerRadius(UIDevice.current.screenCornerRadius(), style: .continuous)
                .onTapGesture(perform: hideKeyboard)
            ScrollView {
                LazyVStack {
                    ForEach((1...30), id: \.self){ item in
                        RoundedRectangle(10)
                            .frame(maxWidth: .infinity)
                            .frame(height: 70)
                            .foregroundColor(.primary)
                            .opacity(0.05)
                            .shimmering()
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, UIDevice.current.statusBarHeight() + 65)
                .padding(.bottom, UIDevice.current.bottomSafeAreaHeight() + 15 + keybaordController.keyboardHeight)
            }
        }
        
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
                        Task{
                            
                        }
                    }
            }
            .padding(.horizontal, 15)
            .background(SearchFieldBackground)
            .textFieldFocusableArea()
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.31) {
//                    isFocused = true
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
        
    }
    
    @ViewBuilder
    private var SearchFieldBackground: some View {
        Color.primary
            .cornerRadius(12, style: .continuous)
            .opacity(0.1)
    }
}
