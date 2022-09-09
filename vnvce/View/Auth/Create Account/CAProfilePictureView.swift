//
//  CAProfilePictureView.swift
//  vnvce
//
//  Created by Kerem Cesme on 23.08.2022.
//

import SwiftUI
import Introspect
import SwiftUIX
import ActionOver

struct CAProfilePictureView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject private var vm: CreateAccountViewModel
    
    @StateObject private var picker = ProfilePictureLibraryViewModel()
    
    @State var navigation = NavigationCoordinator()
    
    @State private var showPicker: Bool = false
    @State private var showAlert: Bool = false
    
    @Sendable
    private func showPickerTask() {
        if vm.profilePicture == nil {
            showPicker = true
            Task(operation: picker.initLibrary)
        } else {
            showAlert = true
        }
        
    }
    
    @Sendable
    private func continueTask() {
        if vm.profilePicture == nil {
            vm.showDisplayNameView = true
        } else {
            Task(operation: vm.editProfilePicture)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top){
                Background
                if vm.profilePicture == nil {
                    VStack(alignment: .leading, spacing: 10) {
                        Description
                        ProfilePictureView.frame(maxWidth: .infinity)
                        SkipOrContinueButton
                    }
                    .padding(.horizontal, 18)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            Description
                            ProfilePictureView.frame(maxWidth: .infinity)
                            AlignmentDescription
                            ProfilePictureAlignmentView
                            SkipOrContinueButton
                        }
                        .padding(.horizontal, 18)
                    }
                }
            }
            .navigationTitle("Profile Picture")
            .navigationBarBackButtonHidden(true)
            .introspectNavigationController(customize: {
                navigation.controller = $0
                $0.delegate = navigation
                $0.interactivePopGestureRecognizer?.delegate = navigation
            })
            .fullScreenCover(isPresented: $showPicker) {
                CAProfilePictureLibraryView().environmentObject(picker)
            }
        }
        .accentColor(.primary)
    }
}

extension CAProfilePictureView {
    
    private var Description: some View {
        Text("You can choose a profile picture so your friends can find you.")
            .foregroundColor(.secondary)
            .font(.system(size: 12, weight: .regular, design: .default))
            .multilineTextAlignment(.leading)
    }
    
    @ViewBuilder
    private var ProfilePictureView: some View {
        VStack(spacing: 5) {
            GeometryReader { g in
                Button(action: showPickerTask) {
                    ZStack {
                        if let image = vm.profilePicture {
                            ZStack {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(g.size)
                                    .clipped()
                                    .opacity(0.75)
                                    .blur(8)
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(g.size)
                                    .clipped()
                            }
                        } else {
                            Color.primary.opacity(0.1)
                            Image(systemName: "person.fill")
                                .foregroundColor(.secondary)
                                .font(.system(size: 44, weight: .medium, design: .default))
                        }
                        
                    }
                }
            }
            .frame(width: UIScreen.main.bounds.width / 2.5, height: (UIScreen.main.bounds.width / 2.5) * 1.333, alignment: .center)
            .cornerRadius(20, style: .continuous)
            .padding(.top, 10)
            
            Text("Choose")
                .foregroundColor(.primary)
                .font(.system(size: 9, weight: .medium, design: .default))
                .padding(.horizontal, 5)
                .padding(.vertical, 2.5)
                .background(ChangeButtonBG)
        }
        .actionOver(presented: $showAlert, title: "Profile Picture", message: nil, buttons: [
            ActionOverButton(
                title: "Remove Current Picture",
                type: .destructive,
                action: {
                    vm.profilePicture = nil
                }),
            ActionOverButton(
                title: "Choose From Library",
                type: .normal,
                action: {
                    showPicker = true
                    Task(operation: picker.initLibrary)
                }
            ),
            ActionOverButton(
                title: nil,
                type: .cancel,
                action: nil
            ),
        ], ipadAndMacConfiguration: IpadAndMacConfiguration(anchor: nil, arrowEdge: nil))
    }
    
    @ViewBuilder
    private var ChangeButtonBG: some View {
        Color.primary.opacity(0.05)
            .cornerRadius(5)
    }
    
    @ViewBuilder
    private var AlignmentDescription: some View {
        if vm.profilePicture != nil {
            VStack(alignment: .leading, spacing: 5) {
                Text("Alignment")
                    .foregroundColor(.primary)
                    .font(.system(size: 26, weight: .semibold, design: .default))
                Text("You can choose how your profile photo will appear as a square or a circle.")
                    .foregroundColor(.secondary)
                    .font(.system(size: 12, weight: .regular, design: .default))
                    .multilineTextAlignment(.leading)
            }
            .padding(.top, 10)
        }
    }
    
    @ViewBuilder
    private var ProfilePictureAlignmentView: some View {
        if let image = vm.profilePicture {
            HStack(spacing: 0) {
                CAProfilePictureAlignmentView(image: image, alignment: .top)
                Spacer()
                CAProfilePictureAlignmentView(image: image, alignment: .center)
                Spacer()
                CAProfilePictureAlignmentView(image: image, alignment: .bottom)
            }
            .offset(0, -10)
            
        }
    }
    
    @ViewBuilder
    private var SkipOrContinueButton: some View {
        Button(action: continueTask) {
            ZStack {
                RoundedRectangle(12, style: .continuous)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .opacity(disabledCondition() ? 0.1 : 1)
                if vm.editProfilePicturePhase == .running {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                        .opacity(0.4)
                } else {
                    Group {
                        if vm.profilePicture == nil {
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
        if vm.editProfilePicturePhase != .none {
            return true
        } else {
            return false
        }
    }
    
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
    
    private var Navigation: some View {
        NavigationLink(isActive: $vm.showDisplayNameView) {
            CADisplayNameView().environmentObject(vm)
        } label: {
            EmptyView()
        }
        .isDetailLink(false)
    }
}

// Navigation Bar
extension CAProfilePictureView {
    @ToolbarContentBuilder
    var ToolBar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) { BackButton }
    }
    
    @ViewBuilder
    var BackButton: some View {
        Button(action: {
            
        }, label: {
            Image(systemName: "chevron.backward")
                .font(.system(size: 18, weight: .medium, design: .default))
                .foregroundColor(.primary)
        })
    }
}

// Navigation Coordinator
extension CAProfilePictureView {
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
