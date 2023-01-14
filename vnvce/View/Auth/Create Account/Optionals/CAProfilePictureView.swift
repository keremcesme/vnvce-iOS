
import SwiftUI

struct CAProfilePictureView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) public var dismiss
    
    @EnvironmentObject public var authVM: AuthViewModel
    
    @State var showPicker = false
    @State var croppedImage: UIImage?
    
    @StateObject private var picker = ProfilePictureLibraryViewModel()
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top, content: BodyView)
                .navigationTitle("Profile Picture")
                .navigationBarTitleDisplayMode(.large)
                .navigationBarBackButtonHidden(true)
                .toolbar(ToolBar)
                .fullScreenCover(isPresented: $showPicker) {
                    CAProfilePictureLibraryView().environmentObject(picker)
                }
//                .cropImagePicker(show: $showPicker, croppedImage: $croppedImage)
        }
        
    }
    
    @ViewBuilder
    private func BodyView() -> some View {
        ColorfulBackgroundView()
        VStack(alignment: .leading, spacing: 10) {
            Button {
                showPicker.toggle()
                Task {
                    await picker.initLibrary()
                }
            } label: {
                Text("Show Picker")
            }

        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 18)
    }
}

extension CAProfilePictureView {
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
