//
//  CACheckPhoneNumberView.swift
//  vnvce
//
//  Created by Kerem Cesme on 12.08.2022.
//

import SwiftUI
import UIKit
import Introspect
import iPhoneNumberField

struct CACheckPhoneNumberView: View {
    @Environment(\.dismiss) var dismiss
    
    @State var navigation = NavigationCoordinator()
    
    @EnvironmentObject var createAccountVM: CreateAccountViewModel
    
    @Sendable
    private func continueButton() {
        Task {
            hideKeyboard()
            await createAccountVM.checkPhoneNumber()
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top){
                Color.init("AuthBG")
                    .ignoresSafeArea()
                    .onTapGesture(perform: hideKeyboard)
                VStack(alignment: .leading, spacing: 10) {
                    Description
                    ErrorMessage
                    PhoneField()
                    ContinueButton
                    TermsAndPrivacy
                }
                .padding(.horizontal, 18)
                .onChange(of: createAccountVM.phoneNumberField) { _ in
                    createAccountVM.phoneNumberPhase = .none
                }
            }
            .navigationTitle("Phone Number")
            .navigationBarBackButtonHidden(true)
            .toolbar(ToolBar)
            .introspectNavigationController(customize: {
                navigation.controller = $0
                $0.delegate = navigation
                $0.interactivePopGestureRecognizer?.delegate = navigation
            })
        }
        .navigationBarHidden(true)
        .accentColor(.primary)
        .onDisappear(perform: hideKeyboard)
    }
    
    @ViewBuilder
    private var Description: some View {
        Text("Each user can open 1 account per phone number. We use your phone number for AUTHENTICATION only.")
            .foregroundColor(.secondary)
            .font(.system(size: 12, weight: .regular, design: .default))
            .multilineTextAlignment(.leading)
    }
    
    @ViewBuilder
    private var ErrorMessage: some View {
        if case let .error(error) = createAccountVM.phoneNumberPhase {
            Text(returnError(error))
                .foregroundColor(.red)
                .font(.system(size: 12, weight: .medium, design: .default))
                .multilineTextAlignment(.leading)
        }
    }
    
    private func returnError(_ error: CheckPhoneNumberError) -> String {
        switch error {
            case .otpExist:
                return error.rawValue
            case .alreadyTaken:
                return error.rawValue
            case .invalidNumber:
                return error.rawValue
            case .taskCancelled, .unknown:
                return error.rawValue
        }
    }
    
    @ViewBuilder
    private var ContinueButton: some View {
        Button(action: continueButton) {
            ZStack {
                RoundedRectangle(12, style: .continuous)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, maxHeight: 60, alignment: .center)
                    .opacity(disabledCondition() ? 0.1 : 1)
                if createAccountVM.phoneNumberPhase == .running {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                        .opacity(0.4)
                } else {
                    Text("Agree & Continue")
                        .colorInvert()
                        .foregroundColor(.primary)
                        .font(.system(size: 22, weight: .semibold, design: .default))
                        .opacity(disabledCondition() ? 0.4 : 1)
                }
            }
        }
        .disabled(disabledCondition())
        .background(Navigation)
    }
    
    private func disabledCondition() -> Bool {
        if createAccountVM.phoneNumberField == "" || createAccountVM.phoneNumberPhase != .none {
            return true
        } else {
            return false
        }
    }
    
    private var TermsAndPrivacy: some View {
        VStack(alignment: .leading, spacing: 1){
            HStack(spacing:0){
                TermsText("By tapping ")
                TermsText("Agree & Create Account", weight: .medium)
                TermsText(", you acknowledge")
            }
            HStack(spacing:0){
                TermsText("that you have read the")
                Button {
                    
                } label: {
                    TermsText(" Privacy Policy  ", color: .pink, weight: .medium)
                }
                TermsText("and agree")
            }
            HStack(spacing:0){
                TermsText("to the")
                    
                Button {
                    
                } label: {
                    TermsText(" Terms of Service", color: .pink, weight: .medium)
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
    private var Navigation: some View {
        NavigationLink(isActive: $createAccountVM.showUsernameView) {
            CAUsernameView().environmentObject(createAccountVM)
        } label: {
            EmptyView()
        }
        .isDetailLink(false)
    }
}


// Phone Number Field
extension CACheckPhoneNumberView {
    private struct PhoneField: View {
        @EnvironmentObject var vm: CreateAccountViewModel
        
        var body: some View {
            HStack {
                iPhoneNumberField(
                    "",
                    text: $vm.phoneNumberField,
                    formatted: true
                )
                .flagHidden(false)
                .flagSelectable(true)
                .placeholderColor(.secondary)
                .font(UIFont(size: 15, weight: .regular, design: .default))
                .onNumberChange(perform: vm.onNumberChange)
                .clearButtonMode(.never)
                .foregroundColor(Color.primary)
                .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: 60, alignment: .center)
                
                
                switch vm.phoneNumberPhase {
                    case .running:
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .secondary))
                    case .success:
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.green)
                    case .error(_):
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.red)
                    case .none: EmptyView()
                }
            }
            .padding(.horizontal, 15)
            .background(Background)
        }
        
        private var Background: some View {
            RoundedRectangle(12, style: .continuous)
                .foregroundColor(.primary)
                .opacity(0.05)
        }
        
    }
    
    
    
}

// Navigation Bar
extension CACheckPhoneNumberView {
    @ToolbarContentBuilder
    var ToolBar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) { BackButton }
    }
    
    @ViewBuilder
    var BackButton: some View {
        Button(action: {
            dismiss()
        }, label: {
            Image(systemName: "chevron.backward")
                .font(.system(size: 18, weight: .medium, design: .default))
                .foregroundColor(.primary)
        })
    }
}

// Navigation Coordinator
extension CACheckPhoneNumberView {
    class NavigationCoordinator: NSObject, UIGestureRecognizerDelegate, UINavigationControllerDelegate {
        var controller: UINavigationController!
        
        var enabled = true
        
        public func gestureRecognizerShouldBegin(
            _ gestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            return false
        }
        
        public func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            false
        }
    }
}
