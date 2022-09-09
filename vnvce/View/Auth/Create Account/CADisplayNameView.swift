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
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: CreateAccountViewModel
    
    @Sendable
    private func editDisplayName() {
        hideKeyboard()
        Task(operation: vm.editDisplayName)
    }
    
    var body: some View {
        ZStack(alignment: .top){
            Background.onTapGesture(perform: hideKeyboard)
            VStack(alignment: .leading, spacing: 10) {
                Description
                DisplayNameField()
                ContinueButton
            }
            .padding(.horizontal, 18)
        }
        .navigationTitle("Display Name")
        .navigationBarBackButtonHidden(true)
        .toolbar(ToolBar)
    }
    
    private var Description: some View {
        Text("You can choose a display name that will appear on your profile.")
            .foregroundColor(.secondary)
            .font(.system(size: 12, weight: .regular, design: .default))
            .multilineTextAlignment(.leading)
    }
    
    @ViewBuilder
    private var ContinueButton: some View {
        Button(action: editDisplayName) {
            ZStack {
                RoundedRectangle(12, style: .continuous)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, maxHeight: 60, alignment: .center)
                    .opacity(disabledCondition() ? 0.1 : 1)
                if vm.editDisplayNamePhase == .running {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                        .opacity(0.4)
                } else {
                    Group {
                        if vm.displayNameField == "" {
                            Text("Skip")
                            
                        } else {
                            Text("Continue")
                        }
                    }
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
        if vm.editDisplayNamePhase == .none {
            if vm.displayNameField.count > 21 {
                return true
            } else {
                return false
            }
        } else {
            return true
        }
    }
    
    private var Navigation: some View {
        NavigationLink(isActive: $vm.showBiographyView) {
            CABiographyView().environmentObject(vm)
        } label: {
            EmptyView()
        }
        .isDetailLink(false)
    }
}

extension CADisplayNameView {
    
    @ViewBuilder
    private var Background: some View {
        Group {
            if let image = vm.profilePicture {
                GeometryReader { g in
                    ZStack {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(g.size)
                            .clipped()
                        switch colorScheme {
                            case .dark:
                                BlurView(style: .systemMaterial)
                                    .overlay(Color.black.opacity(0.5))
                            case .light:
                                BlurView(style: .systemMaterial)
                            @unknown default:
                                EmptyView()
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                Color.init("AuthBG")
            }
        }
        .ignoresSafeArea()
    }
}

// Navigation Bar
extension CADisplayNameView {
    @ToolbarContentBuilder
    var ToolBar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) { BackButton }
    }
    
    @ViewBuilder
    var BackButton: some View {
        if vm.profilePicture == nil {
            Button(action: {
                dismiss()
            }, label: {
                Image(systemName: "chevron.backward")
                    .font(.system(size: 18, weight: .medium, design: .default))
                    .foregroundColor(.primary)
            })
        }
    }
}

extension CADisplayNameView {
    private struct DisplayNameField: View {
        @EnvironmentObject var vm: CreateAccountViewModel
        
        init() {}
        
        @Sendable
        private func task() {
            
        }
        
        var body: some View {
            Group {
                if #available(iOS 15.0, *) {
                    TextField("Display Name", text: $vm.displayNameField)
                        .submitLabel(.done)
                        .onSubmit(task)
                } else {
                    TextField("Display Name", text: $vm.displayNameField)
                }
            }
            .font(.system(size: 15, weight: .regular, design: .default))
            .keyboardType(.default)
            .autocapitalization(.words)
            .disableAutocorrection(true)
            .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: 60, alignment: .center)
            .padding(.horizontal, 15)
            .background(Background)
            .textFieldFocusableArea()
        }
        
        private var Background: some View {
            RoundedRectangle(12, style: .continuous)
                .foregroundColor(.primary)
                .opacity(0.05)
        }
        
    }
}
