
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
            Text("Friends on vnvce")
                .font(.system(size: 16, weight: .semibold, design: .default))
                .foregroundColor(.white)
                .padding(.leading, 10)
                .padding(.bottom, -10)
            UsersView
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder
    private var UsersView: some View {
        LazyVStack(alignment: .leading, spacing: 10) {
            ForEach(contactsVM.users, id: \.id, content: UserCell)
        }
        .padding(10)
        .background {
            RoundedRectangle(12, style: .continuous)
                .fill(.white.opacity(0.05))
        }
    }
    
    @ViewBuilder
    private func UserCell(_ user: User.Public) -> some View {
        VStack(spacing: 10) {
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            } label: {
                HStack(spacing: 10){
                    ZStack {
                        if let picture = user.profilePictureURL {
                            Group {
                                Image("me")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 59, height: 59)
                                BlurView(style: .dark)
                                    .frame(width: 60, height: 60)
                                Image("me")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 52, height: 52)
                            }
                            .clipShape(Circle())
                        } else {
                            Group {
                                Color.white.opacity(0.1)
                                    .frame(width: 60, height: 60)
                                Color.white.opacity(0.1)
                                    .frame(width: 52, height: 52)
                            }
                            .clipShape(Circle())
                            
                            if let displayName = user.displayName {
                                Text(displayName[0])
                                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                    .opacity(0.7)
                            } else {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                    .opacity(0.75)
                            }
                        }
                    }
                    VStack(alignment: .leading, spacing: 2.5) {
                        if let displayName = user.displayName {
                            Text(displayName)
                                .font(.system(size: 16, weight: .semibold, design: .default))
                                .foregroundColor(.white)
                            Text(user.username)
                                .font(.system(size: 14, weight: .regular, design: .default))
                                .foregroundColor(.secondary)
                        } else {
                            Text(user.username)
                                .font(.system(size: 16, weight: .semibold, design: .default))
                                .foregroundColor(.white)
                        }
                        Text("IN MY CONTACTS")
                            .font(.system(size: 10, weight: .light, design: .default))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.system(size: 13, weight: .semibold, design: .default))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(ScaledButtonStyle())
            if user.id != contactsVM.users.last?.id {
                Divider()
            }
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
