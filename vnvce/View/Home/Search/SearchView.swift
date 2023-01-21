
import SwiftUI
import SwiftUIX
import PureSwiftUI

struct SearchView: View {
    @Environment(\.dismiss) public var dismiss
    
    @EnvironmentObject public var searchVM: SearchViewModel
    
    @FocusState public var focused: Bool
    
    private func offsetTask(_ value: CGFloat) {
        self.searchVM.scrollOffset = -(value - UIDevice.current.statusBarHeight() - 54)
    }
    
    private func search(_ value: String) {
        searchVM.searchFirstPage(value)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Background
            ScrollView {
                VStack(spacing: 20) {
                    SearchResults
                }
                .offsetY(offsetTask)
                .frame(maxWidth: .infinity)
                .padding(.top, 120)
                .padding(.horizontal, 20)
            }
            .onTapGesture(perform: hideKeyboard)
            TopBackground
            SearchField
        }
        .cornerRadius(UIDevice.current.screenCornerRadius, corners: [.topLeft, .topRight])
        .ignoresSafeArea()
        .colorScheme(.dark)
        .onChange(of: searchVM.searchField, perform: searchVM.onChangeSearchField)
        .onReceive(searchVM.$searchText.debounce(for: 0.5, scheduler: RunLoop.main), perform: search)
        .taskInit {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                focused = true
            }
        }
    }
    
    @ViewBuilder
    private var Background: some View {
        BlurView(style: .systemMaterialDark)
            .background {
                Image("me")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(UIScreen.main.bounds.size)
            }
            .background(.black)
            .overlay(.black.opacity(0.5))
            .ignoresSafeArea()
    }
    
    
    
    @ViewBuilder
    private var TopBackground: some View {
        LinearGradient(colors: [.black.opacity(0.5), .clear], startPoint: .top, endPoint: .bottom)
            .frame(maxWidth: .infinity)
            .frame(height: UIDevice.current.statusBarHeight() + 70)
            .opacity(searchVM.scrollOffset / 10)
            .ignoresSafeArea()
    }
}
