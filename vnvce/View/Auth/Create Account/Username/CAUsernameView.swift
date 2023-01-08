//
//  CAUsernameView.swift
//  vnvce
//
//  Created by Kerem Cesme on 12.08.2022.
//

import SwiftUI

struct CAUsernameView: View {
    @Environment(\.colorScheme) public var colorScheme
    @Environment(\.dismiss) public var dismiss
    
    @EnvironmentObject public var authVM: AuthViewModel
    
    
    public func continueButton() {
        Task {
            hideKeyboard()
            await authVM.reserveUsernameAndSendOTP()
        }
    }
    
    var body: some View {
        ZStack(alignment: .top, content: BodyView)
            .navigationTitle("Username")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden(true)
            .toolbar(ToolBar)
    }
    
    @ViewBuilder
    private func BodyView() -> some View {
        ColorfulBackgroundView()
        VStack(alignment: .leading, spacing: 10) {
            Description
            UsernameField
            Criteria
            Spacer()
            ContinueButton
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 18)
//            .onChange(of: vm.usernameField) { _ in
//                if vm.usernameField.isEmpty {
//                    vm.checkUsernamePhase = .none
//                } else {
//                    vm.checkUsernamePhase = .running
//                }
//            }
//            .onReceive(vm.$usernameField.debounce(for: 0.8, scheduler: RunLoop.main), perform: autoCheckUsername)
    }
}














// MARK: Text Field -
//extension CAUsernameView {
//    private struct UsernameField: View {
//        @EnvironmentObject var vm: CreateAccountViewModel
//
//        @FocusStateLegacy var focused: Bool?
//
//        init() {}
//
//        private func task() {
//
//        }
//
//        var body: some View {
//            HStack {
//                HStack(spacing: 5) {
//                    Image(systemName: "person.fill")
//                        .foregroundColor(vm.usernameField.isEmpty ? .secondary : .primary)
//                        .font(.system(size: 18, weight: .medium, design: .default))
//                        .frame(width: 18, height: 18, alignment: .center)
//
//                    Group {
//                        if #available(iOS 15.0, *) {
//                            TextField("Username", text: $vm.usernameField)
//                                .submitLabel(.done)
//                                .onSubmit(task)
//                        } else {
//                            TextField("Username", text: $vm.usernameField)
//                        }
//                    }
//                    .font(.system(size: 15, weight: .regular, design: .default))
//                    .keyboardType(.default)
//                    .autocapitalization(.none)
//                    .disableAutocorrection(true)
////                    .focusedLegacy($focused, equals: true)
//                    .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: 60, alignment: .center)
//                }
//
//                switch vm.checkUsernamePhase {
//                    case .running:
//                        ProgressView()
//                            .progressViewStyle(CircularProgressViewStyle(tint: .secondary))
//                    case .success:
//                        switch vm.reserveUsernameAndSendOTPPhase {
//                            case .running, .success, .none:
//                                Image(systemName: "checkmark.circle.fill")
//                                    .font(.system(size: 18, weight: .medium))
//                                    .foregroundColor(.green)
//                            case .error(_):
//                                Image(systemName: "xmark.circle.fill")
//                                    .font(.system(size: 18, weight: .medium))
//                                    .foregroundColor(.red)
//                        }
//                    case .error(_):
//                        Image(systemName: "xmark.circle.fill")
//                            .font(.system(size: 18, weight: .medium))
//                            .foregroundColor(.red)
//                    case .none: EmptyView()
//                }
//            }
//            .padding(.horizontal, 15)
//            .background(Background)
//            .textFieldFocusableArea()
//            .onAppear {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                    focused = true
//                }
//            }
////            .onChange(of: vm.reserveUsernameAndSendOTPPhase) {
////                if $0 == .success {
////                    focused = nil
////                }
////            }
//        }
//
//        private var Background: some View {
//            RoundedRectangle(12, style: .continuous)
//                .foregroundColor(.primary)
//                .opacity(0.05)
//        }
//    }
//}


