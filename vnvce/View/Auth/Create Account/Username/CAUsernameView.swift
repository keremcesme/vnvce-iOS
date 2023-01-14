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
            hideKeyboard()
            authVM.reserveUsernameAndSendOTP()
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
    }
}
