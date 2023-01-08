
import SwiftUI

extension CAVerifyPhoneNumberView {
    @ToolbarContentBuilder
    var ToolBar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) { BackButton }
    }
    
    @ViewBuilder
    private var BackButton: some View {
        Button(action: dismiss) {
            Image(systemName: "chevron.backward")
                .font(.system(size: 18, weight: .medium, design: .default))
                .foregroundColor(.primary)
        }
    }
}
