
import SwiftUI
import SwiftUIX
import PureSwiftUI

extension SearchView {
    private func onPress() {
        focused = true
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
                    .onSubmit { searchVM.searchFirstPage(searchVM.searchText) }
            }
            .padding(.horizontal, 18)
            .background {
                ZStack {
                    Color.white.opacity(min(1.0 - searchVM.scrollOffset / 10, 0.1))
                    BlurView(style: .dark).opacity(searchVM.scrollOffset / 10)
                }
                .cornerRadius(12, style: .continuous)
            }
            .contentShape(Rectangle())
            .onPress(perform: onPress)
            .overlay(LoadingIndicator, alignment: .trailing)
            
            Button(action: dismiss) {
                Text("Cancel")
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .semibold, design: .default))
            }
            
        }
        .padding(.horizontal, 18)
        .padding(.top, UIDevice.current.statusBarHeight() + 4)
        
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
