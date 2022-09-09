//
//  AuthView.swift
//  vnvce
//
//  Created by Kerem Cesme on 12.08.2022.
//

import SwiftUI
import UIKit
import Introspect
import PureSwiftUI

struct AuthView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State var navigation = NavigationCoordinator()
    
    @StateObject var createAccountVM: CreateAccountViewModel
    
    init() {
        self._createAccountVM = StateObject(wrappedValue: CreateAccountViewModel())
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom){
                Color.init("AuthBG")
                    .ignoresSafeArea()
                VStack(alignment: .leading, spacing: 0){
                    Button {
                        
                    } label: {
                        Text("TEST")
                            .padding()
                    }

                    Logo
                    CreateAccount
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 18)
            }
            
            .introspectNavigationController(customize: {
                navigation.controller = $0
                $0.delegate = navigation
                $0.interactivePopGestureRecognizer?.delegate = navigation
            })
        }
    }
    
    @ViewBuilder
    private var Logo: some View {
        HStack {
            Text("vnvce")
                .font(.system(size: 36, weight: .bold, design: .default))
        }
    }
    
    @ViewBuilder
    private var CreateAccount: some View {
        Button {
            createAccountVM.phoneNumberField = ""
            createAccountVM.phoneNumber = nil
            createAccountVM.phoneNumberPhase = .none
            
            createAccountVM.regionCode = nil
            
            createAccountVM.show = true
        } label: {
            VStack(alignment: .leading, spacing: 5){
                Text("Don't have an account?")
                    .foregroundColor(.secondary)
                    .font(.system(size: 14, weight: .regular, design: .default))
                HStack{
                    Text("Create account")
                    Image(systemName: "chevron.forward.circle.fill")
                }
                .foregroundColor(.primary)
                .font(.system(size: 16, weight: .medium, design: .default))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 15)
        }
        .background(CreateAccountNavigation)
    }
    
    private var CreateAccountNavigation: some View {
        NavigationLink(isActive: $createAccountVM.show) {
            CACheckPhoneNumberView().environmentObject(createAccountVM)
        } label: {
            EmptyView()
        }
        .isDetailLink(false)
    }
}

extension AuthView {
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
