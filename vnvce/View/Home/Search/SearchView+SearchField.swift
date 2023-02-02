
import SwiftUI
import SwiftUIX
import PureSwiftUI

extension SearchView {
    private func onPress() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        focused = true
    }
    
    @ViewBuilder
    public var SearchField: some View {
        HStack(spacing: 0) {
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
                    .frame(height: 50)
                    .onSubmit { searchVM.searchFirstPage(searchVM.searchText) }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .padding(.horizontal, 18)
            .background(.white.opacity(0.1))
            .cornerRadius(12, style: .continuous)
            .contentShape(Rectangle())
            .onPress(perform: onPress)
            .buttonStyle(ScaledButtonStyle())
            .overlay(LoadingIndicator, alignment: .trailing)
            
            if focused {
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    focused = false
                } label: {
                    Text("Cancel")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .semibold, design: .default))
                }
                .buttonStyle(ScaledButtonStyle())
                .transition(.move(edge: .trailing).combined(with: .opacity))
                .padding(.leading, 18)
            }
            
        }
        .padding(.horizontal, 18)
        .padding(.top, 10)
        .animation(.easeOut(duration: 0.2), value: focused)
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
