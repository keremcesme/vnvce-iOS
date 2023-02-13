//
//  SearchView+SearchResults.swift
//  vnvce
//
//  Created by Kerem Cesme on 22.01.2023.
//

import SwiftUI

extension SearchView {
    @ViewBuilder
    public var SearchResults: some View {
        LazyVStack(alignment: .leading, spacing: 20) {
            if !searchVM.searchText.isEmpty {
                ForEach(searchVM.searchResults.items, id: \.id, content: UserCell)
                if searchVM.isRunning {
                    RedactedUserCell
                }
            }
        }
    }
    
    @ViewBuilder
    private func UserCell(_ user: User.Public) -> some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            HStack(spacing: 10){
                ZStack {
                    if let picture = user.profilePictureURL {
                        Group {
                            Image("me")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 59, height: 59)
                            BlurView(style: .dark)
                                .frame(width: 60, height: 60)
                            Image("me")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 52, height: 52)
                        }
                        .clipShape(Circle())
                        
                    } else {
                        Group {
                            Color.white.opacity(0.1)
                                .frame(width: 60, height: 60)
                            Color.white.opacity(0.1)
                                .frame(width: 52, height: 52)
                        }
                        .clipShape(Circle())
                        
                        if let displayName = user.displayName {
                            Text(displayName[0])
                                .font(.system(size: 22, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .opacity(0.7)
                        } else {
                            Image(systemName: "person.fill")
                                .font(.system(size: 28, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .opacity(0.75)
                        }
                    }
                }
                VStack(alignment: .leading, spacing: 2.5) {
                    if let displayName = user.displayName {
                        Text(displayName)
                            .font(.system(size: 16, weight: .semibold, design: .default))
                            .foregroundColor(.white)
                        Text(user.username)
                            .font(.system(size: 14, weight: .regular, design: .default))
                            .foregroundColor(.secondary)
                    } else {
                        Text(user.username)
                            .font(.system(size: 16, weight: .semibold, design: .default))
                            .foregroundColor(.white)
                    }
                    
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.system(size: 13, weight: .semibold, design: .default))
            }
            .contentShape(Rectangle())
        }
        
        .buttonStyle(ScaledButtonStyle())
    }
    
    @ViewBuilder
    public var RedactedUserCell: some View {
        ForEach(1...15, id: \.self) { _ in
            HStack(spacing:10){
                Circle()
                    .fill(.white)
                    .frame(width: 60, height: 60)
                
                VStack(alignment: .leading, spacing: 5) {
                    Capsule()
                        .frame(width: 175, height: 5, alignment: .center)
                    Capsule()
                        .frame(width: 100, height: 5, alignment: .center)
                }
                .foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.white)
                    .font(.system(size: 13, weight: .semibold, design: .default))
            }
            .opacity(0.1)
        }
        .shimmering()
    }
}

