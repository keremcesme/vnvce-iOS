//
//  CABiographyView.swift
//  vnvce
//
//  Created by Kerem Cesme on 24.08.2022.
//

import SwiftUI
import Introspect

struct CABiographyView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: CreateAccountViewModel
    @EnvironmentObject private var appState: AppState
    
    @Sendable
    private func finishTask() {
        hideKeyboard()
        Task {
            await vm.editBiography {
                DispatchQueue.main.async {
                    self.appState.loggedIn = true
                    self.vm.showProfilePictureView = false
                }
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .top){
            Background.onTapGesture(perform: hideKeyboard)
            VStack(alignment: .leading, spacing: 10) {
                Description
                BiographyField()
                FinishButton
            }
            .padding(.horizontal, 18)
        }
        .navigationTitle("Biography")
        .navigationBarBackButtonHidden(true)
        .toolbar(ToolBar)
    }
    
    private var Description: some View {
        Text("You can write a short biography about you.")
            .foregroundColor(.secondary)
            .font(.system(size: 12, weight: .regular, design: .default))
            .multilineTextAlignment(.leading)
    }
    
    @ViewBuilder
    private var FinishButton: some View {
        Button(action: finishTask) {
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
                        if vm.biographyField == "" {
                            Text("Skip & Finish")
                            
                        } else {
                            Text("Finish")
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
    }
    
    private func disabledCondition() -> Bool {
        if vm.editBiographyPhase == .none {
            if vm.biographyField.count > 140 {
                return true
            } else {
                return false
            }
            
        } else {
            return true
        }
    }
}

// Navigation Bar
extension CABiographyView {
    @ToolbarContentBuilder
    var ToolBar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) { BackButton }
    }
    
    @ViewBuilder
    var BackButton: some View {
        if vm.displayNameField == "" {
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

extension CABiographyView {
    
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

extension CABiographyView {
    private struct BiographyField: View {
        @EnvironmentObject var vm: CreateAccountViewModel
        
        var body: some View {
            VStack {
                TextEditor(text: $vm.biographyField)
                    .font(.system(size: 15, weight: .regular, design: .default))
                    .keyboardType(.default)
                    .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height * 0.2, alignment: .center)
                    .background(.clear)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.primary.opacity(0.05).cornerRadius(10))
                    .textEditorFocusableArea()
                    .padding(.top, 15)
                    .introspectTextView { textView in
                        textView.backgroundColor = .clear
                    }
                HStack{
                    Spacer()
                    Text("\(140 - vm.biographyField.count)")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(140 - vm.biographyField.count <= 3 ? Color.red : Color.primary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.primary.opacity(0.05).cornerRadius(5))
                }
            }
        }
    }
}
