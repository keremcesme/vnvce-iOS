//
//  EditProfileView.swift
//  vnvce
//
//  Created by Kerem Cesme on 8.09.2022.
//

import SwiftUI
import Introspect
import Nuke
import NukeUI
import PureSwiftUI
import SwiftUIX

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject private var currentUserVM: CurrentUserViewModelOLD
    
    var body: some View {
        NavigationView {
            ZStack {
                CurrentUserBackground()
                VStack {
                    List {
                        Group {
                            Section(header: "Profile Picture") {
                                NavigationLink {
                                    CurrentUserBackground()
                                } label: {
                                    if let profilePicture = currentUserVM.user?.profilePicture {
                                        LazyImage(url: URL(string: profilePicture.url)) { state in
                                            if let uiImage = state.imageContainer?.image {
//                                                Image(uiImage: uiImage)
//                                                    .resizable()
//                                                    .aspectRatio(contentMode: .fill)
//                                                    .frame(width: 100, height: 100, alignment: profilePicture.alignment.convert)
//                                                    .cornerRadius(7.5, style: .continuous)
////                                                    .padding(.vertical, 10)
                                            }
                                        }
                                        .pipeline(.shared)
                                        .processors([ImageProcessors.Resize(width: 100)])
                                        .priority(.normal)
                                    }
                                }
                                .listRowInsets(EdgeInsets(2.5, 2.5, 2.5, 15))
                            }
                            
                            
                            NavigationLink {
                                CurrentUserBackground()
                            } label: {
                                VStack(alignment: .leading, spacing: 2.5){
                                    Text("USERNAME")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("kerem")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                }
                                .padding(.vertical, 5)
                            }

                            NavigationLink {
                                CurrentUserBackground()
                            } label: {
                                VStack(alignment: .leading, spacing: 2.5){
                                    Text("DISPLAY NAME")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("Kerem Cesme")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                }
                                .padding(.vertical, 5)
                            }
                            
                            NavigationLink {
                                CurrentUserBackground()
                            } label: {
                                VStack(alignment: .leading, spacing: 2.5){
                                    Text("BIOGRAPHY")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("Founder at Socialayf")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                }
                                .padding(.vertical, 5)
                            }
                            
                        }
                        .introspectTableViewCell { cell in
                            let selection = UIView()
                            selection.backgroundColor = UIColor.systemGroupedBackground
                            let background = UIView()
                            background.backgroundColor = UIColor(Color.primary.opacity(0.05))
                            cell.selectedBackgroundView = selection
                            cell.backgroundView = background
                        }
                        .listRowBackground(Color.primary.opacity(0.05))
                    }
                    .listStyle(.automatic)
                    .introspectTableView { tableView in
                        tableView.backgroundColor = .clear
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .toolbar(ToolBar)
        }
        .accentColor(.primary)
    }
}

private extension EditProfileView {
    @ToolbarContentBuilder
    var ToolBar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) { BackButton }
//        ToolbarItem(placement: .principal) { Title }
        ToolbarItem(placement: .navigationBarTrailing) { SaveButton }
    }
    
    @ViewBuilder
    var BackButton: some View {
        Button(action: {
            dismiss()
        }, label: {
            Image(systemName: "xmark").font(.headline)
                .foregroundColor(.primary)
        })
    }
    
    @ViewBuilder
    var Title: some View {
        Text("Edit Profile").font(.headline)
    }
    
    @ViewBuilder
    var SaveButton: some View {
        Text("Save")
            .foregroundColor(.primary)
            .font(.system(size: 16, weight: .semibold, design: .default))
    }
}
