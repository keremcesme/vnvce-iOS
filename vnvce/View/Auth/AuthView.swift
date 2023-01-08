
import SwiftUI
import SwiftUIX
import PureSwiftUI

struct AuthView: View {
    @StateObject private var authVM: AuthViewModel
    
    @State private var showContinueButton = false
    
    init() {
        self._authVM = StateObject(wrappedValue: AuthViewModel())
    }
    
    var body: some View {
        NavigationView {
            BodyView
                .navigationBarHidden(true)
        }
        .environmentObject(authVM)
    }
    
    @ViewBuilder
    private var BodyView: some View {
        ZStack(alignment: .bottom){
            ColorfulBackgroundView()
            VStack(alignment: .leading, spacing: 0){
                Logo
                PhoneNumberView
                Spacer()
                CreateAccount
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 18)
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
    }
    
    @ViewBuilder
    private var Logo: some View {
        HStack(spacing: 10) {
            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(32)
            Text("vnvce")
                .font(.system(size: 48, weight: .heavy, design: .default))
                .yOffset(-6)
        }
        .padding(.top, 44)
    }
    
    @ViewBuilder
    private var PhoneNumberView: some View {
        VStack(alignment: .leading, spacing: 5) {
            Description
            VStack(alignment: .leading, spacing: 10) {
                PhoneNumberField
                ContinueButton
            }
        }
        .padding(.top, 44)
        .onChange(of: authVM.loginPhoneNumber.number) { num in
            withAnimation(.easeInOut(duration: 0.2)) {
                showContinueButton = num != ""
            }
        }
    }
    
    @ViewBuilder
    private var Description: some View {
        Text("Phone Number")
            .foregroundColor(.secondary)
            .font(.system(size: 14, weight: .regular, design: .default))
            .padding(.horizontal, 12)
    }
    
    @ViewBuilder
    private var PhoneNumberField: some View {
        PhoneNumberFieldUI($authVM.loginPhoneNumber)
            .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: 60, alignment: .center)
            .padding(.horizontal, 15)
            .background {
                RoundedRectangle(12, style: .continuous)
                    .foregroundColor(.primary)
                    .opacity(0.05)
            }
    }
    
    @ViewBuilder
    private var ContinueButton: some View {
        if showContinueButton {
            Button {
                
            } label: {
                RoundedRectangle(12, style: .continuous)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, maxHeight: 60, alignment: .center)
                    .overlay {
                        Text("Continue")
                            .colorInvert()
                            .foregroundColor(.primary)
                            .font(.system(size: 22, weight: .semibold, design: .default))
                    }
                    .transition(.opacity)
            }
        }
    }
    
    @ViewBuilder
    private var CreateAccount: some View {
        Button(action: authVM.showCreateAction) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Don't have an account?")
                        .foregroundColor(.secondary)
                        .font(.system(size: 14, weight: .regular, design: .default))
                    
                    Text("Create account")
                        .font(.system(size: 22, weight: .bold, design: .default))
                        .foregroundStyle(.linearGradient(
                            colors: [Color.init(hex: "53E6CA"), Color.init(hex: "6A3FFB")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing))
                }
                Spacer()
                Image(systemName: "chevron.forward.circle.fill")
                    .foregroundColor(.primary)
                    .font(.system(size: 16, weight: .medium, design: .default))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(15)
            .background {
                RoundedRectangle(12, style: .continuous)
                    .foregroundColor(.primary)
                    .opacity(0.05)
            }
        }
        .background(CreateAccountNavigation)
        .padding(.bottom, 18)
        
    }
    
    private var CreateAccountNavigation: some View {
        NavigationLink(isActive: $authVM.showCreateView) {
            CACheckPhoneNumberView()
        } label: {
            EmptyView()
        }
        .isDetailLink(false)
    }
}
