//
//  UserProfileView.swift
//  vnvce
//
//  Created by Kerem Cesme on 11.09.2022.
//

import SwiftUI
import Introspect

struct UserProfileView: View {
    @Environment(\.dismiss) var dismiss
    
    private let user: User.Public
    
    init(user: User.Public) {
        self.user = user
    }
    
    var body: some View {
        NavigationView {
            Text("Hello, World!")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbar(ToolBar)
        }
        .navigationBarHidden(true)
    }
}

extension UserProfileView {
    
    @ToolbarContentBuilder
    private var ToolBar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) { BackButton }
        ToolbarItem(placement: .principal) { UsernameLabel }
    }
    
    @ViewBuilder
    var BackButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "chevron.back").font(.headline)
                .foregroundColor(.primary)
        }
    }
    
    @ViewBuilder
    private var UsernameLabel: some View {
        Text(user.username)
            .font(.headline)
            .frame(width: 150, alignment: .center)
    }
}
