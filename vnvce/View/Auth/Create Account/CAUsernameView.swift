//
//  CAUsernameView.swift
//  vnvce
//
//  Created by Kerem Cesme on 12.08.2022.
//

import SwiftUI
import Focuser

struct CAUsernameView: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: CreateAccountViewModel
    
    private func autoCheckUsername(_ username: String) {
        Task(operation: vm.autoCheckUsername)
    }
    
    private func reserveUsername() {
        hideKeyboard()
        Task(operation: vm.reserveUsernameAndSendOTP)
//        vm.showVerifyView = true
    }
    
    var body: some View {
        ZStack(alignment: .top){
            Color.init("AuthBG")
                .ignoresSafeArea()
                .onTapGesture(perform: hideKeyboard)
            VStack(alignment: .leading, spacing: 10) {
                Description
                ErrorMessage
                UsernameField()
                ContinueButton
                Criteria
            }
            .padding(.horizontal, 18)
            .onChange(of: vm.usernameField) { _ in
                if vm.usernameField.isEmpty {
                    vm.checkUsernamePhase = .none
                } else {
                    vm.checkUsernamePhase = .running
                }
            }
            .onReceive(vm.$usernameField.debounce(for: 0.8, scheduler: RunLoop.main), perform: autoCheckUsername)
        }
        .navigationTitle("Username")
        .navigationBarBackButtonHidden(true)
        .toolbar(ToolBar)
    }
    
    private var Description: some View {
        Text("Choose a unique username for yourself so your friends can find you. You can change it later whenever you want.")
            .foregroundColor(.secondary)
            .font(.system(size: 12, weight: .regular, design: .default))
            .multilineTextAlignment(.leading)
    }
    
    @ViewBuilder
    private var ErrorMessage: some View {
        if case let .error(error) = vm.checkUsernamePhase {
            Text(returnError(error))
                .foregroundColor(.red)
                .font(.system(size: 12, weight: .medium, design: .default))
                .multilineTextAlignment(.leading)
        } else if case let .error(error) = vm.reserveUsernameAndSendOTPPhase {
            Text(returnError2(error))
                .foregroundColor(.red)
                .font(.system(size: 12, weight: .medium, design: .default))
                .multilineTextAlignment(.leading)
        }
    }
    
    private func returnError(_ error: CheckUsernameError) -> String {
        switch error {
            case .invalidUsername:
                return error.rawValue
            case .alreadyTaken:
                return error.rawValue
            case .reserved:
                return "This username cannot be used."
            case .taskCancelled, .unknown:
                return error.rawValue
        }
    }
    
    private func returnError2(_ error: ReserveUsernameAndSendOTPError) -> String {
        switch error {
            case .usernameAlreadyTaken:
                return error.rawValue
            case .usernameIsReserved:
                return "This username cannot be used."
            case .numberAlreadyTaken:
                return "This phone number cannot be used."
            case .otpExist:
                return error.rawValue
            case .taskCancelled, .unknown:
                return error.rawValue
        }
    }
    
    @ViewBuilder
    private var ContinueButton: some View {
        Button(action: reserveUsername) {
            ZStack {
                RoundedRectangle(12, style: .continuous)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, maxHeight: 60, alignment: .center)
                    .opacity(disabledCondition() ? 0.1 : 1)
                if vm.reserveUsernameAndSendOTPPhase == .running {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                        .opacity(0.4)
                } else {
                    Text("Continue")
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
        if vm.checkUsernamePhase == .success && vm.reserveUsernameAndSendOTPPhase == .none {
            return false
        } else {
            return true
        }
    }
    
    private var Criteria: some View {
        VStack(alignment: .leading, spacing: 6){
            Text("Username criteria:")
                .font(.system(size: 12, weight: .medium, design: .default))
                .foregroundColor(.secondary)
            VStack(alignment: .leading, spacing:3){
                Group{
                    Text("• Must be at least 3 and at most 20 characters long.")
                    Text("• It must contain at least 2 letters.")
                    Text("• Only numbers, letters, \"_\" and \".\" can be used.")
                    Text("• Only English letters can be used.")
                    Text("• It cannot start with \"_\" and \".\"")
                    Text("• \" _ \" and \" . \" cannot come together.")
                }
                .font(.system(size: 10, weight: .regular, design: .default))
                .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var Navigation: some View {
        NavigationLink(isActive: $vm.showVerifyView) {
            CAVerifyPhoneNumberView().environmentObject(vm)
        } label: {
            EmptyView()
        }
        .isDetailLink(false)
    }
}

// Navigation Bar
extension CAUsernameView {
    @ToolbarContentBuilder
    var ToolBar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) { BackButton }
    }
    
    @ViewBuilder
    var BackButton: some View {
        Button(action: {
            dismiss()
            vm.phoneNumberPhase = .none
        }, label: {
            Image(systemName: "chevron.backward")
                .font(.system(size: 18, weight: .medium, design: .default))
                .foregroundColor(.primary)
        })
    }
}

// MARK: Text Field -
extension CAUsernameView {
    private struct UsernameField: View {
        @EnvironmentObject var vm: CreateAccountViewModel
        
        @FocusStateLegacy var focused: Bool?
        
        init() {}
        
        private func task() {
            
        }
        
        var body: some View {
            HStack {
                HStack(spacing: 5) {
                    Image(systemName: "person.fill")
                        .foregroundColor(vm.usernameField.isEmpty ? .secondary : .primary)
                        .font(.system(size: 18, weight: .medium, design: .default))
                        .frame(width: 18, height: 18, alignment: .center)
                    
                    Group {
                        if #available(iOS 15.0, *) {
                            TextField("Username", text: $vm.usernameField)
                                .submitLabel(.done)
                                .onSubmit(task)
                        } else {
                            TextField("Username", text: $vm.usernameField)
                        }
                    }
                    .font(.system(size: 15, weight: .regular, design: .default))
                    .keyboardType(.default)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
//                    .focusedLegacy($focused, equals: true)
                    .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: 60, alignment: .center)
                }
                
                switch vm.checkUsernamePhase {
                    case .running:
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .secondary))
                    case .success:
                        switch vm.reserveUsernameAndSendOTPPhase {
                            case .running, .success, .none:
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.green)
                            case .error(_):
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.red)
                        }
                    case .error(_):
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.red)
                    case .none: EmptyView()
                }
            }
            .padding(.horizontal, 15)
            .background(Background)
            .textFieldFocusableArea()
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    focused = true
                }
            }
//            .onChange(of: vm.reserveUsernameAndSendOTPPhase) {
//                if $0 == .success {
//                    focused = nil
//                }
//            }
        }
        
        private var Background: some View {
            RoundedRectangle(12, style: .continuous)
                .foregroundColor(.primary)
                .opacity(0.05)
        }
    }
}


