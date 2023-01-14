
import SwiftUI

extension CAVerifyPhoneNumberView {
    @ToolbarContentBuilder
    var ToolBar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) { BackButton }
        ToolbarItem(placement: .navigationBarTrailing) { ActivityIndicator }
    }
    
    @ViewBuilder
    private var BackButton: some View {
        Button(action: dismiss) {
            Image(systemName: "chevron.backward")
                .font(.system(size: 18, weight: .medium, design: .default))
                .foregroundColor(authVM.createAccountIsRunning ? .secondary : .primary)
        }
        .disabled(authVM.createAccountIsRunning)
    }
    
    @ViewBuilder
    var ActivityIndicator: some View {
        if authVM.createAccountIsRunning {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(.secondary)
        }
    }
    
}
