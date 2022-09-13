//
//  CAVerifyPhoneNumberView.swift
//  vnvce
//
//  Created by Kerem Cesme on 12.08.2022.
//

import SwiftUI
import Focuser

struct CAVerifyPhoneNumberView: View {
    @KeychainStorage("accessToken") var accessToken
    @KeychainStorage("refreshToken") var refreshToken
    
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject private var sceneDelegate: SceneDelegate
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var vm: CreateAccountViewModel
    
    @StateObject private var timer = SMSTimerController()
    
    private func timerInit() {
        guard let attempt = vm.smsAttempt else {
//            dismiss()
            return
        }
        timer.commonInit(start: attempt.startTime, expire: attempt.expiryTime)
    }
    
    private func resendSMSOTP() {
        Task {
            await vm.resendSMSOTP()
            guard let attempt = vm.smsAttempt else {
                return
            }
            timer.commonInit(start: attempt.startTime, expire: attempt.expiryTime)
        }
    }
    
    private func createAccount() {
        Task {
            hideKeyboard()
            guard let success = await vm.createAccount() else {
                return
            }
            timer.stop()
            refreshToken = success.tokens.refreshToken
            accessToken = success.tokens.accessToken
            appState.currentUserID = success.user.id.uuidString
            sceneDelegate.accountIsCreated = true
            vm.showProfilePictureView = true
            print("Refresh Token: \(refreshToken)")
            print("Access Token: \(accessToken)")
            print("Current User ID: \(appState.currentUserID)")
        }
    }
    
    var body: some View {
        ZStack(alignment: .top){
            Color.init("AuthBG")
                .ignoresSafeArea()
                .onTapGesture(perform: hideKeyboard)
            VStack(alignment: .leading, spacing: 10) {
                Description
                ErrorMessage
                OTPTextField()
                    .onChange(of: vm.otpField) { _ in
                        vm.createAccountPhase = .none
                    }
                ContinueButton
            }
            .padding(.horizontal, 18)
        }
        .navigationTitle("Verify Phone")
        .navigationBarBackButtonHidden(true)
        .toolbar(ToolBar)
        .taskInit(timerInit)
        .fullScreenCover(isPresented: $vm.showProfilePictureView) {
            CAProfilePictureView()
        }
    }
    
    @ViewBuilder
    private var Description: some View {
        if let region = vm.regionCode  {
            Text("Enter the code sent to \"\(region) \(vm.phoneNumberField)\".")
                .foregroundColor(.secondary)
                .font(.system(size: 12, weight: .regular, design: .default))
                .multilineTextAlignment(.leading)
            VStack(alignment: .leading, spacing: 5){
                Text("Didn't get the code?")
                    .foregroundColor(Color.secondary)
                    .font(.system(size: 12, weight: .regular, design: .default))
                if timer.remaining > 0 {
                    Text("You can request a new code after \(timer.remaining) seconds.")
                        .foregroundColor(Color.secondary)
                        .font(.system(size: 10, weight: .regular, design: .default))
                } else {
                    Button(action: resendSMSOTP) {
                        if vm.resendSMSOTPPhase == .running {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .secondary))
                        } else {
                            Label("Resend code", systemImage: "arrow.counterclockwise")
                                .foregroundColor(Color.primary)
                                .font(.system(size: 12, weight: .semibold, design: .default))
                        }
                    }
                    .disabled(vm.resendSMSOTPPhase == .running)
                }
            }
            Divider()
        }
    }
    
    @ViewBuilder
    private var ErrorMessage: some View {
        if case let .error(error) = vm.createAccountPhase {
            Text(returnError(error))
                .foregroundColor(.red)
                .font(.system(size: 12, weight: .medium, design: .default))
                .multilineTextAlignment(.leading)
        }
    }
    
    private func returnError(_ error: CreateAccountError) -> String {
        switch error {
            case .otpNotVerified:
                return error.rawValue
            case .otpExpired:
                return error.rawValue
            case .taskCancelled, .unknown:
                return error.rawValue
        }
    }
    
    @ViewBuilder
    private var ContinueButton: some View {
        Button(action: createAccount){
            ZStack {
                RoundedRectangle(12, style: .continuous)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, maxHeight: 60, alignment: .center)
                    .opacity(disabledCondition() ? 0.1 : 1)
                if vm.createAccountPhase == .running {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                        .opacity(0.4)
                } else {
                    Text("Create Account")
                        .colorInvert()
                        .foregroundColor(.primary)
                        .font(.system(size: 22, weight: .semibold, design: .default))
                        .opacity(disabledCondition() ? 0.4 : 1)
                }
                
            }
        }
        .disabled(disabledCondition())
    }
    
    private func disabledCondition() -> Bool {
        if vm.otpField.count != 6 || vm.createAccountPhase != .none{
            return true
        } else {
            return false
        }
    }
    
//    private var Navigation: some View {
//        NavigationLink(isActive: $vm.showProfilePictureView) {
//            CAProfilePictureView()
//        } label: {
//            EmptyView()
//        }
//        .isDetailLink(false)
//
//    }
    
}

// Navigation Bar
extension CAVerifyPhoneNumberView {
    @ToolbarContentBuilder
    var ToolBar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) { BackButton }
    }
    
    @ViewBuilder
    var BackButton: some View {
        Button(action: {
            dismiss()
            vm.reserveUsernameAndSendOTPPhase = .none
        }, label: {
            Image(systemName: "chevron.backward")
                .font(.system(size: 18, weight: .medium, design: .default))
                .foregroundColor(.primary)
        })
    }
}

extension CAVerifyPhoneNumberView {
    
    private struct OTPTextField: View {
        @EnvironmentObject var vm: CreateAccountViewModel
        
        @FocusStateLegacy var focused: Bool?
        
        init() {}
        
        var body: some View {
            HStack {
                Image(systemName: "key.fill")
                    .foregroundColor(vm.usernameField.isEmpty ? .secondary : .primary)
                    .font(.system(size: 18, weight: .medium, design: .default))
                    .frame(width: 18, height: 18, alignment: .center)
                
                Group {
                    if #available(iOS 15.0, *) {
                        TextField("", text: $vm.otpField)
                    } else {
                        TextField("", text: $vm.otpField)
                    }
                }
                .font(.system(size: 15, weight: .regular, design: .default))
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .autocapitalization(.none)
                .disableAutocorrection(true)
//                .focusedLegacy($focused, equals: true)
                .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: 60, alignment: .center)
//                Availability
                switch vm.createAccountPhase {
                    case .running:
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .secondary))
                    case .success(_):
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
            .textFieldFocusableArea()
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    focused = true
                }
            }
        }
        
        private var Background: some View {
            RoundedRectangle(12, style: .continuous)
                .foregroundColor(.primary)
                .opacity(0.05)
        }
        
    }
    
//    @ViewBuilder
//    private var OTPTextField: some View {
//        TextField("", text: $otpField)
//            .keyboardType(.numberPad)
//            .textContentType(.oneTimeCode)
//            .autocapitalization(.none)
//            .disableAutocorrection(true)
//            .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: 60, alignment: .center)
//            .padding(.horizontal, 15)
//            .background(Background)
//            .textFieldFocusableArea()
//    }
//
//    private var Background: some View {
//        RoundedRectangle(12, style: .continuous)
//            .foregroundColor(.primary)
//            .opacity(0.05)
//    }
    
}

// OTP Field
//extension CAVerifyPhoneNumberView {
//
//    @ViewBuilder
//    private var OTPField: some View {
//        HStack(spacing:14) {
//            ForEach(0..<6, id: \.self){ index in
//                VStack(spacing: 8) {
//                    TextField("", text: $otpVM.otpFields[index], onEditingChanged: {
//                        if !$0 {
//                            otpVM.otpFields[index] = ""
//                        }
//                    })
//                        .keyboardType(.numberPad)
//                        .textContentType(.oneTimeCode)
//                        .multilineTextAlignment(.center)
//                        .focusedLegacy($activeField, equals: activeStateForIndex(index: index))
//                        .onChange(of: activeField) {
//                            if $0 == activeStateForIndex(index: index) && $0 != .field6{
//                                otpVM.otpFields[index] = ""
//                            }
//                        }
//                    Rectangle()
//                        .fill(activeField == activeStateForIndex(index: index) ? .blue : .secondary)
//                        .frame(height: 2)
//                }
//                .frame(width: 30)
//            }
//        }
//        .frame(maxWidth: .infinity, alignment: .center)
//        .padding(.horizontal, 18)
//        .onAppear(perform: {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                activeField = .field1
//            }
//        })
//        .onChange(of: otpVM.otpFields) { newValue in
//            OTPCondition(value: newValue)
//        }
//    }
//
//    private func OTPCondition(value: [String]) {
//
//        for index in 0..<6 {
//            if value[index].count == 6 {
//                DispatchQueue.main.async {
//                    otpVM.otpText = value[index]
//                    otpVM.otpFields[index] = ""
//                    for item in otpVM.otpText.enumerated() {
//                        otpVM.otpFields[item.offset] = String(item.element)
//                    }
//                }
//                return
//            }
//        }
//
//        for index in 0..<5 {
//            if value[index].count == 1 && activeStateForIndex(index: index) == activeField {
//                activeField = activeStateForIndex(index: index + 1)
//            }
//        }
//
////        for index in 1...5 {
////            if value[index].isEmpty && !value[index - 1].isEmpty {
////                activeField = activeStateForIndex(index: index - 1)
////            }
////        }
//
//        for index in 0..<6 {
//            if value[index].count > 1 {
//                otpVM.otpFields[index] = String(value[index].last!)
//            }
//        }
//    }
//
//    private func activeStateForIndex(index: Int) -> OTPField {
//        switch index {
//            case 0: return .field1
//            case 1: return .field2
//            case 2: return .field3
//            case 3: return .field4
//            case 4: return .field5
//            default: return .field6
//        }
//    }
//
//}
