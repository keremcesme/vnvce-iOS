
import SwiftUI
import SwiftUIX
import PureSwiftUI
import SwiftyContacts
import PhoneNumberKit

struct SearchView: View {
    @Environment(\.dismiss) public var dismiss
    
    @EnvironmentObject public var searchVM: SearchViewModel
    @EnvironmentObject public var contactsVM: ContactsViewModel
    
    @FocusState public var focused: Bool
    
    private func offsetTask(_ value: CGFloat) {
        self.searchVM.scrollOffset = -(value - UIDevice.current.statusBarHeight() - 54)
    }
    
    private func search(_ value: String) {
        searchVM.searchFirstPage(value)
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Background
                VStack(alignment: .leading, spacing: 0){
                    SearchField
                    
                    Divider()
                        .padding(.top, 10)
                    
                    ScrollView(content: ScrollContent)
                        .onTapGesture(perform: hideKeyboard)
                }
            }
            .clearBackground()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(Toolbar)
        }
        .cornerRadius(UIDevice.current.screenCornerRadius, corners: [.topLeft, .topRight])
        .ignoresSafeArea()
        .colorScheme(.dark)
        .onChange(of: searchVM.searchField, perform: searchVM.onChangeSearchField)
        .onReceive(searchVM.$searchText.debounce(for: 0.5, scheduler: RunLoop.main), perform: search)
    }
    
    @ViewBuilder
    private func ScrollContent() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            if !searchVM.searchText.isEmpty {
                SearchResults
            } else {
                UsersFromContacts
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 18)
        .padding(.top, 10)
    }
    
    
    
    @ViewBuilder
    private var Background: some View {
        BlurView(style: .systemMaterialDark)
//            .background {
//                Image("me")
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .frame(UIScreen.main.bounds.size)
//            }
//            .background(.black )
            .overlay(.black.opacity(0.2))
//        ZStack {
//            Color.black
//            ColorfulBackgroundView()
//                .overlay(.black.opacity(0.2))
//        }
        
            .ignoresSafeArea()
    }
    
}

extension SearchView {
    @ToolbarContentBuilder
    public var Toolbar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) { Title }
        ToolbarItem(placement: .navigationBarTrailing) { DismissButton }
    }
    
    @ViewBuilder
    private var Title: some View {
        Text("Add your friends")
            .foregroundColor(.white)
            .font(.system(size: 22, weight: .bold, design: .default))
            .padding(.leading, 12)
    }
    
    @ViewBuilder
    private var DismissButton: some View {
        Button(action: dismiss) {
            Image(systemName: "xmark")
                .foregroundColor(.white)
                .font(.system(size: 18, weight: .semibold, design: .default))
                .contentShape(Rectangle())
        }
        .buttonStyle(ScaledButtonStyle())
    }
}
