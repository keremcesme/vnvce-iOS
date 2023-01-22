
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
        ZStack(alignment: .top) {
            Background
            ScrollView(content: ScrollContent)
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
            
//            Task {
//                do {
//                    if try await requestAccess() {
//                        let status = authorizationStatus()
//                        if status == .authorized {
//
//                            let contacts = try await fetchContacts()
//                            let phoneNumberKit = PhoneNumberKit()
//
//                            print("Count: \(contacts.count)")
//                            for user in contacts {
//                                let name = "\(user.givenName) \(user.familyName)"
//                                print("Name: \(name)")
//                                let phoneNumbers = user.phoneNumbers.map({$0.value.stringValue})
//
////                                print("Raw Number: \(phoneNumbers.first ?? "null")")
//
//                                for (inx, number) in phoneNumbers.enumerated() {
//                                    if let phoneNumber = try? phoneNumberKit.parse(number) {
//                                        print("[\(inx + 1)] Phone Number: \(phoneNumber.regionID ?? "null") +\(phoneNumber.countryCode)\(phoneNumber.nationalNumber)")
//                                    }
//                                }
//                                print("----------------------------------------------------------")
//                            }
//
//                        }
//                    }
//                } catch {
//                    print(error.localizedDescription)
//                }
//
//            }
            
        }
    }
    
    @ViewBuilder
    private func ScrollContent() -> some View {
        LazyVStack(alignment: .leading, spacing: 20) {
            if !searchVM.searchText.isEmpty {
                SearchResults
            } else {
                UsersFromContacts
            }
        }
        .offsetY(offsetTask)
        .frame(maxWidth: .infinity)
        .padding(.top, 120)
        .padding(.horizontal, 18)
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
