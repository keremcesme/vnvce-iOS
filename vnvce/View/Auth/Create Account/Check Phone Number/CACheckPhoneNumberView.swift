//
//  CACheckPhoneNumberView.swift
//  vnvce
//
//  Created by Kerem Cesme on 12.08.2022.
//

import SwiftUI
import UIKit
import Introspect

struct CACheckPhoneNumberView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var authVM: AuthViewModel
    
    @State var navigation = NavigationCoordinator()
    
    private func continueButton() {
        hideKeyboard()
        authVM.checkPhoneNumber()
    }
    
    var body: some View {
            ZStack(alignment: .top){
                ColorfulBackgroundView()
                VStack(alignment: .leading, spacing: 10) {
                    Description
                    PhoneNumberField
                    ErrorMessage
                    Spacer()
                    TermsAndPrivacy
                    ContinueButton
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 18)
            }
            .navigationTitle("Phone Number")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden(true)
            .toolbar(ToolBar)
    }
    
    @ViewBuilder
    private var Description: some View {
        Text("Create your account using your phone number. Only one account can be created with a phone number. No one can see your phone number and we only use it for account security.")
            .foregroundColor(.secondary)
            .font(.system(size: 12, weight: .regular, design: .default))
            .multilineTextAlignment(.leading)
    }
    
    @ViewBuilder
    private var PhoneNumberField: some View {
        HStack(spacing: 5) {
            PhoneNumberFieldUI($authVM.createPhoneNumber)
                .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: 60, alignment: .center)
            if let result = authVM.checkPhoneNumberResult, result.error {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.red)
            }
        }
        .padding(.horizontal, 15)
        .background {
            RoundedRectangle(12, style: .continuous)
                .foregroundColor(.primary)
                .opacity(0.05)
        }
        .onChange(of: authVM.createPhoneNumber.number, perform: authVM.onChangeShowAgreeAndContinueButton)
    }
    
    @ViewBuilder
    private var ErrorMessage: some View {
        if let result = authVM.checkPhoneNumberResult, result.error {
            Text("This phone number cannot be used. Please try again later.")
                .foregroundColor(.red)
                .font(.system(size: 12, weight: .medium, design: .default))
                .multilineTextAlignment(.leading)
        }
    }
    
    @ViewBuilder
    private var ContinueButton: some View {
        Button(action: continueButton) {
            ZStack {
                RoundedRectangle(12, style: .continuous)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, maxHeight: 60, alignment: .center)
                    .opacity(buttonDisabled() ? 0.1 : 1)
                if !authVM.checkPhoneNumberIsRunning {
                    ButtonText
                } else {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.secondary)
                }
                
            }
        }
        .disabled(buttonDisabled())
        .background(DateOfBirthNavigation)
        .padding(.bottom, 18)
    }
    
    private func buttonDisabled() -> Bool {
        if !authVM.showAgreeAndContinueButton || authVM.checkPhoneNumberIsRunning {
            return true
        } else {
            return false
        }
    }
    
    @ViewBuilder
    private var ButtonText: some View {
        let text = "Agree & Continue"
        Group {
            if authVM.showAgreeAndContinueButton {
                Text(text)
                    .foregroundStyle(.linearGradient(
                        colors: [Color.init(hex: "53E6CA"), Color.init(hex: "6A3FFB")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing))
            } else {
                Text(text)
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                    .opacity(0.4)
            }
        }
        .font(.system(size: 22, weight: .semibold, design: .default))
    }
    
    private var TermsAndPrivacy: some View {
        VStack(alignment: .leading, spacing: 1){
            HStack(spacing:0){
                TermsText("By tapping ")
                TermsText("Agree & Continue", weight: .medium)
                TermsText(", you acknowledge")
            }
            HStack(spacing:0){
                TermsText("that you have read the")
                Button {
                    
                } label: {
                    TermsText(" Privacy Policy  ", color: .mint, weight: .medium)
                }
                TermsText("and agree")
            }
            HStack(spacing:0){
                TermsText("to the")
                    
                Button {
                    
                } label: {
                    TermsText(" Terms of Service", color: .mint, weight: .medium)
                }
                TermsText(".")
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    @ViewBuilder
    private func TermsText(
        _ text: String,
        color: Color = .secondary,
        weight: Font.Weight = .light
    ) -> some View {
        Text(text)
            .foregroundColor(color)
            .font(.system(size: 10, weight: weight, design: .default))
    }
    
    // Navigation Link
    private var DateOfBirthNavigation: some View {
        NavigationLink(isActive: $authVM.showDateOfBirthView) {
            CADateOfBirthView().environmentObject(authVM)
        } label: {
            EmptyView()
        }
        .isDetailLink(false)
    }
}

// Navigation Bar
extension CACheckPhoneNumberView {
    @ToolbarContentBuilder
    var ToolBar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) { BackButton }
        ToolbarItem(placement: .navigationBarTrailing) { ActivityIndicator }
    }
    
    @ViewBuilder
    var BackButton: some View {
        Button(action: dismiss) {
            Image(systemName: "chevron.backward")
                .font(.system(size: 18, weight: .medium, design: .default))
                .foregroundColor(authVM.checkPhoneNumberIsRunning ? .secondary : .primary)
        }
        .disabled(authVM.checkPhoneNumberIsRunning)
    }
    
    @ViewBuilder
    var ActivityIndicator: some View {
        if authVM.checkPhoneNumberIsRunning {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(.secondary)
        }
    }
}
