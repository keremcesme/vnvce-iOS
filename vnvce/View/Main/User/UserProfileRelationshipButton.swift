//
//  UserProfileRelationshipButton.swift
//  vnvce
//
//  Created by Kerem Cesme on 25.09.2022.
//

import SwiftUI
import ActionOver

struct UserProfileRelationshipButton: View {
    @StateObject public var userVM: UserProfileViewModel
    
    @State private var showAlert: Bool = false
    
    init(userVM: UserProfileViewModel) {
        self._userVM = StateObject(wrappedValue: userVM)
    }
    
    
    @Sendable
    private func action() async {
        switch userVM.relationship!.raw  {
        case .nothing:
            await userVM.sendFriendRequest()
        case .friendRequestReceived:
            await userVM.acceptFriendRequest()
        case .friend, .friendRequestSubmitted:
            showAlert = true
        default: return
        }
    }
    
    private func alertAction() {
        Task {
            switch userVM.relationship!.raw {
            case .friend:
                await userVM.removeFriend()
            case .friendRequestSubmitted:
                await userVM.undoOrRejectFriendRequest()
            default: return
            }
        }
    }
    
    private var alertButtonTitle: String {
        switch userVM.relationship!.raw {
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
        .alert(isPresented: $userVM.showUpdateRelationshipAlert) {
            Alert(title: Text("An error occurred"),
                  message: Text("Your relationship with the user changed before you pressed the button."),
                  dismissButton: .default(Text("Got it!")))
        }
    }
    
    @ViewBuilder
    private var RelationshipLabel: some View {
        if let relationship = userVM.relationship?.raw {
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
            .disabled(userVM.relationshipIsUpdating)
            .actionOver(presented: $showAlert,
                        title: userVM.user.displayName ?? userVM.user.username,
                        message: "Are you sure?",
                        buttons: [
                            ActionOverButton(title: alertButtonTitle, type: .destructive, action: alertAction),
                            ActionOverButton(title: nil, type: .cancel, action: nil),
                        ],
                        ipadAndMacConfiguration: IpadAndMacConfiguration(anchor: nil, arrowEdge: nil))
            
        } else {
            SecondaryLabel("Loading", icon: false)
        }
    }
    
    @ViewBuilder
    private var RejectRequestLabel: some View {
        if case .friendRequestReceived = userVM.relationship?.raw {
            AsyncButton {
                await userVM.undoOrRejectFriendRequest()
            } label: {
                SecondaryLabel("Reject", icon: false)
            }
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
