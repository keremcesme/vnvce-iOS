//
//  CADisplayNameView.swift
//  vnvce
//
//  Created by Kerem Cesme on 24.08.2022.
//

import SwiftUI
import Introspect
import SwiftUIX

struct CADisplayNameView: View {
    @Environment(\.colorScheme) public var colorScheme
    
    @EnvironmentObject public var authVM: AuthViewModel
    
    private func continueButton() {
        hideKeyboard()
        authVM.editDisplayName()
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top, content: BodyView)
                .navigationTitle("Display Name")
                .navigationBarTitleDisplayMode(.large)
                .navigationBarBackButtonHidden(true)
                .toolbar(ToolBar)
        }
    }
    
    @ViewBuilder
    private func BodyView() -> some View {
        ColorfulBackgroundView()
        VStack(alignment: .leading, spacing: 10) {
            Description
            DisplayNameField
            Spacer()
            ContinueButton
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 18)
    }
    
    private var Description: some View {
        Text("You can choose a display name so your friends can easily understand who you are.")
            .foregroundColor(.secondary)
            .font(.system(size: 12, weight: .regular, design: .default))
            .multilineTextAlignment(.leading)
    }
    
    @ViewBuilder
    private var DisplayNameField: some View {
        HStack(spacing: 5) {
            TextField("Display Name", text: $authVM.displayName)
                .font(.system(size: 22, weight: .bold))
                .autocapitalization(.words)
                .disableAutocorrection(true)
                .submitLabel(.done)
                .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: 60, alignment: .center)
        }
        .padding(.horizontal, 15)
        .background {
            RoundedRectangle(12, style: .continuous)
                .foregroundColor(.primary)
                .opacity(0.05)
        }
    }
    
    @ViewBuilder
    public var ContinueButton: some View {
        Button(action: continueButton) {
            ZStack {
                RoundedRectangle(12, style: .continuous)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, maxHeight: 60, alignment: .center)
                    .opacity(buttonDisabled() ? 0.1 : 1)
                if !authVM.editDisplayNameTaskIsRunning {
                    ButtonText
                } else {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.secondary)
                }
            }
        }
        .disabled(buttonDisabled())
        .padding(.bottom, 18)
        .background(EditBiographyNavigation)
    }
    
    private func buttonDisabled() -> Bool {
        if authVM.reserveUsernameSendOTPIsRunning {
            return true
        } else {
            return false
        }
    }
    
    @ViewBuilder
    private var ButtonText: some View {
        let text = authVM.displayName == "" ? "Skip" : "Continue"
        Text(text)
            .foregroundStyle(.linearGradient(
                colors: [Color.init(hex: "53E6CA"), Color.init(hex: "6A3FFB")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing))
        .font(.system(size: 22, weight: .semibold, design: .default))
    }
    
    // Navigation Link
    private var EditBiographyNavigation: some View {
        NavigationLink(isActive: $authVM.showBiographyView) {
            CABiographyView()
        } label: {
            EmptyView()
        }
        .isDetailLink(false)
    }
    
    @ToolbarContentBuilder
    var ToolBar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) { ActivityIndicator }
    }
    
    @ViewBuilder
    var ActivityIndicator: some View {
        if authVM.editDisplayNameTaskIsRunning {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(.secondary)
        }
    }
}
