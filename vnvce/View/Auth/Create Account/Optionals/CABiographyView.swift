//
//  CABiographyView.swift
//  vnvce
//
//  Created by Kerem Cesme on 24.08.2022.
//

import SwiftUI
import Introspect

struct CABiographyView: View {
    @Environment(\.colorScheme) public var colorScheme
    @EnvironmentObject public var authVM: AuthViewModel
    
    private func finishTask() {
        hideKeyboard()
        authVM.editBiography()
    }
    
    var body: some View {
        ZStack(alignment: .top, content: BodyView)
            .navigationTitle("Biography")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden(true)
            .toolbar(ToolBar)
    }
    
    @ViewBuilder
    private func BodyView() -> some View {
        ColorfulBackgroundView()
        VStack(alignment: .leading, spacing: 10) {
            Description
//            DisplayNameField
            Spacer()
//            ContinueButton
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 18)
    }
    
    private var Description: some View {
        Text("You can write a short biography about you.")
            .foregroundColor(.secondary)
            .font(.system(size: 12, weight: .regular, design: .default))
            .multilineTextAlignment(.leading)
    }
    
    @ToolbarContentBuilder
    var ToolBar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) { ActivityIndicator }
    }
    
    @ViewBuilder
    var ActivityIndicator: some View {
        if authVM.editBiographyTaskIsRunning {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(.secondary)
        }
    }
    
}
