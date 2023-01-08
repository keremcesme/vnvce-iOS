//
//  ProfileView+NavigationBar.swift
//  vnvce
//
//  Created by Kerem Cesme on 6.11.2022.
//

import SwiftUI

extension ProfileView {
    
    @ToolbarContentBuilder
    public var ToolBar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) { NavigationBar_Back }
        ToolbarItem(placement: .principal) { NavigationBar_Username }
    }
    
    @ViewBuilder
    private var NavigationBar_Back: some View {
        Button {
//            self.rootVM.showHome()
            dismiss()
        } label: {
            Image(systemName: "chevron.backward")
                .foregroundColor(.primary)
                .font(.system(size: 20, weight: .medium, design: .default))
        }
    }
    
    @ViewBuilder
    private var NavigationBar_Username: some View {
        Text(currentUserVM.user?.username ?? "")
            .font(.headline)
            .frame(width: 150, alignment: .center)
    }
    
}
