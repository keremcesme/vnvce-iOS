
import SwiftUI

extension UserProfileView {
    @ToolbarContentBuilder
    public var ToolBar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) { BackButton }
//        ToolbarItem(placement: .principal) { UsernameLabel }
    }
    
    @ViewBuilder
     private var BackButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "chevron.backward").font(.headline)
                .foregroundColor(.primary)
        }
    }
    
    @ViewBuilder
    private var UsernameLabel: some View {
        Text(userVM.user.username)
            .font(.headline)
            .frame(width: 150, alignment: .center)
    }
}
