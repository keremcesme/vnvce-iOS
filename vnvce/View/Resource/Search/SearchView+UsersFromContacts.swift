
import SwiftUI

extension SearchView {
    
    @ViewBuilder
    public var UsersFromContacts: some View {
        switch contactsVM.configuration {
        case .permissionDenied, .permissionNotDetermined, .permissionRestricted:
            LazyVStack(alignment: .leading, spacing: 5) {
                Text("Friends on vnvce")
                    .font(.system(size: 16, weight: .semibold, design: .default))
                    .foregroundColor(.white)
                    .padding(.leading, 10)
                PermissionView
            }
        case .success:
            if !contactsVM.users.isEmpty {
                Text("Friends on vnvce")
                    .font(.system(size: 16, weight: .semibold, design: .default))
                    .foregroundColor(.white)
                    .padding(.leading, 10)
                    .padding(.bottom, -10)
                UsersView
            }
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder
    private var UsersView: some View {
        LazyVStack(alignment: .leading, spacing: 10) {
            ForEach(contactsVM.users, id: \.id) { UserCellView($0)}
        }
        .padding(10)
        .background {
            RoundedRectangle(12, style: .continuous)
                .fill(.white.opacity(0.05))
        }
    }
    
    @ViewBuilder
    private var PermissionView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text("Allow vnvce to access your contacts")
                    .font(.system(size: 16, weight: .semibold, design: .default))
                    .foregroundColor(.primary)
                Text("To be able to view your friends who have a vnvce account in their contacts.")
                    .font(.system(size: 13, weight: .regular, design: .default))
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.secondary)
                PermissionButton
                    .padding(.top, 5)
            }
            Spacer()
        }
        .padding(10)
        .background {
            RoundedRectangle(12, style: .continuous)
                .fill(.white.opacity(0.1))
        }
    }
    
    private func permissionButton() {
        if contactsVM.configuration == .permissionNotDetermined {
            Task {
                await contactsVM.requestContactsAccess()
            }
        } else if contactsVM.configuration == .permissionDenied {
            contactsVM.openSettings()
        }
    }
    
    @ViewBuilder
    private var PermissionButton: some View{
        Button(action: permissionButton) {
            Text(contactsVM.configuration.buttonTitle)
                .foregroundStyle(.linearGradient(
                    colors: [Color.init(hex: "53E6CA"), Color.init(hex: "6A3FFB")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing))
                .font(.system(size: 14, weight: .semibold, design: .default))
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
                .background(Capsule().fill(.white))
        }
    }
}
