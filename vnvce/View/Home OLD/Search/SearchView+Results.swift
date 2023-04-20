//
//  SearchView+Results.swift
//  vnvce
//
//  Created by Kerem Cesme on 11.11.2022.
//

import SwiftUI
import SwiftUIX
import PureSwiftUI
import Nuke
import NukeUI

extension SearchViewOLD2 {
    
    @ViewBuilder
    public var SearchResults: some View {
        ForEach(searchVM.searchResults.items, id: \.id, content: UserCell)
    }
    
    @ViewBuilder
    private func UserCell(_ user: User.PublicOLD) -> some View {
        NavigationLink {
            UserProfileViewOLD(user: user)
                .environmentObject(currentUserVM)
                .environmentObject(navigationController)
        } label: {
            HStack(spacing: 10) {
                if let profilepicture = user.profilePicture {
                    LazyImage(url: URL(string: profilepicture.url)) { state in
                        if let uiImage = state.imageContainer?.image {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 50, alignment: .center)
                                .cornerRadius(10, style: .continuous)
                        } else {
                            RoundedRectangle(10, style: .continuous)
                                .foregroundColor(.secondary)
                                .frame(width: 50, height: 50, alignment: .center)
                        }
                    }
                    .pipeline(.shared)
                    .processors([ImageProcessors.Resize(width: 50)])
                    .priority(.normal)
                } else {
                    RoundedRectangle(10, style: .continuous)
                        .foregroundColor(.secondary)
                        .frame(width: 50, height: 50, alignment: .center)
                }
                
                VStack(alignment: .leading) {
                    Text(user.displayName ?? "")
                        .font(.system(size: 16, weight: .semibold, design: .default))
                        .foregroundColor(.primary)
                    Text(user.username)
                        .font(.system(size: 14, weight: .regular, design: .default))
                        .foregroundColor(.secondary)
                }
                .foregroundColor(Color.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(Color(.systemGray2))
                    .font(.system(size: 11, weight: .semibold, design: .default))
            }
            .padding(10)
            .background{
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .foregroundColor(.primary)
                    .opacity(0.05)
            }
        }
        .isDetailLink(false)
    }
}
