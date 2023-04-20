
import SwiftUI
import ActionOver

extension UserProfileView {
    struct RelationshipButton: View {
        @StateObject public var userVM: UserProfileViewModel
        
        @State private var showAlert: Bool = false
        
        init(_ userVM: UserProfileViewModel) {
            self._userVM = StateObject(wrappedValue: userVM)
        }
        
        @Sendable
        private func action() async {
            if let relationship = userVM.relationship {
                switch relationship  {
                case .nothing:
                    await userVM.sendFriendRequest()
                case .friendRequestReceived:
                    await userVM.acceptFriendRequest()
                case .friend, .friendRequestSubmitted:
                    showAlert = true
                default: return
                }
            }
            
        }
        
        private func alertAction() {
            Task {
                if let relationship = userVM.relationship {
                    switch relationship {
                    case .friend:
                        await userVM.removeFriend()
                    case .friendRequestSubmitted:
                        await userVM.undoOrRejectFriendRequest()
                    default: return
                    }
                }
            }
        }
        
        private var alertButtonTitle: String {
            switch userVM.relationship {
            case .friend:
                return "Remove Friend"
            case .friendRequestSubmitted:
                return "Undo Friend Request"
            default: return ""
            }
        }
        
        var body: some View {
            HStack(spacing: 10){
                RelationshipLabel
                RejectRequestLabel
            }
            .padding(.top, 10)
            .alert(isPresented: $userVM.showRelationshipAlert) {
                Alert(title: Text("An error occurred"),
                      message: Text("Your relationship with the user changed before you pressed the button."),
                      dismissButton: .default(Text("Got it!")))
            }
        }
        
        @ViewBuilder
        private var RelationshipLabel: some View {
            if userVM.relationshipIsUpdating {
                SecondaryLabel("Loading", icon: false)
            } else {
                if let relationship = userVM.relationship {
                    AsyncButton(action: action) {
                        switch relationship {
                        case .nothing:
                            PrimaryLabel("Add", icon: true)
                        case .friend:
                            SecondaryLabel("Friend")
                        case .friendRequestSubmitted:
                            SecondaryLabel("Undo Request")
                        case .friendRequestReceived:
                            PrimaryLabel("Accept")
                        case .blocked:
                            Text("")
                        default: EmptyView()
                        }
                    }
                    .buttonStyle(ScaledButtonStyle())
                    .disabled(userVM.relationshipIsUpdating)
                    .actionOver(isPresented: $showAlert,
                                title: userVM.user.displayName ?? userVM.user.username,
                                message: "Are you sure?",
                                buttons: actionButtons)
                } else {
                    SecondaryLabel("Loading", icon: false)
                }
            }
            
        }
        
        private var actionButtons: [ActionOverButton] {
            return [
                .init(title: alertButtonTitle, type: .destructive, action: alertAction),
                .init(title: nil, type: .cancel, action: nil)
            ]
        }
        
        @ViewBuilder
        private var RejectRequestLabel: some View {
            if case .friendRequestReceived = userVM.relationship {
                AsyncButton {
                    await userVM.undoOrRejectFriendRequest()
                } label: {
                    SecondaryLabel("Reject", icon: false)
                }
                .buttonStyle(ScaledButtonStyle())
                .disabled(userVM.relationshipIsUpdating)
            }
        }
        
        @ViewBuilder
        private func PrimaryLabel(_ title: String, icon: Bool = false) -> some View {
            HStack(spacing:3) {
                Text(title)
                if icon {
                    Image(systemName: "plus")
                }
            }
            .font(.system(size: 15, weight: .medium, design: .default))
            .foregroundColor(.primary)
            .colorInvert()
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(ButtonBackground())
        }
        
        @ViewBuilder
        private func SecondaryLabel(_ title: String, icon: Bool = true) -> some View {
            HStack(spacing:3) {
                Text(title)
                    .font(.system(size: 15, weight: .medium, design: .default))
                if icon {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 9, weight: .medium, design: .default))
                }
            }
            .foregroundColor(.secondary)
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(ButtonBackground(true))
        }
        
        @ViewBuilder
        private func ButtonBackground(_ transparent: Bool = false) -> some View {
            RoundedRectangle(cornerRadius: 7.5, style: .continuous)
                .foregroundColor(Color.primary)
                .opacity(transparent ? 0.1 : 1)
        }
        
    }
}
