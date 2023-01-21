//
//  TabBar.swift
//  vnvce
//
//  Created by Kerem Cesme on 19.10.2022.
//

import SwiftUI
import SwiftUIX
import PureSwiftUI
import Nuke
import NukeUI

struct TabBar: View {
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject private var tabBarVM: TabBarViewModel
    @EnvironmentObject private var currentUserVM: CurrentUserViewModel
    @EnvironmentObject private var camera: CameraManager
    
    var body: some View {
        VStack {
            Spacer()
            TabBar
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
    
    @ViewBuilder
    private var TabBar: some View {
        GeometryReader{
            let size = $0.size
            Group {
                if tabBarVM.current == .camera {
                    Color.white
                } else {
                    Color.primary
                }
            }
            .frame(size)
            HStack(spacing: 26) {
                TabBarItem(.feed)
                TabBarItem(.camera)
                TabBarItem(.profile)
            }
            .padding(4)
        }
        .frame(width: 252, height: 38)
        .clipShape(Capsule())
        .padding(.bottom, UIDevice.current.hasNotch() ? 0 : 15)
    }
    
    @ViewBuilder
    private func TabBarItem(_ tab: TabOLD) -> some View {
            ZStack {
                Capsule()
                    .foregroundColor(tabBarVM.current == .camera ? .white : .primary)
                    .colorInvert()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .opacity(tabBarVM.current == tab ? 1 : 0)
                if tab == .profile, let url = currentUserVM.user?.profilePicture?.url {
                    LazyImage(url: URL(string: url)) { state in
                        if let uiImage = state.imageContainer?.image {
                            Circle()
                                .foregroundColor(iconColor(.profile))
                                .frame(21)
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(19)
                                .clipShape(Circle())
                        } else {
                            Circle()
                                .foregroundColor(iconColor(.profile))
                                .frame(21)
                                .shimmering()
                        }
                    }
                    .pipeline(.shared)
                    .processors([ImageProcessors.Resize(width: 19)])
                    .priority(.veryHigh)
                } else {
                    Image(tab == tabBarVM.current ? tab.fill : tab.name)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .foregroundColor(iconColor(tab))
                        .frame(width: 18, height: 18, alignment: .center)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                tabBarVM.current = tab
                if tab == .camera {
                    UIDevice.current.setStatusBar(style: .lightContent, animation: false)
                    if camera.image == nil {
                        camera.startSession()
                    }
                } else {
                    UIDevice.current.setStatusBar(style: .default, animation: false)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        if tabBarVM.current != .camera {
                            camera.stopSession()
                        }
                    }
                }
            }

    }
    
    private func iconColor(_ tab: TabOLD) -> Color {
        if tabBarVM.current == .camera {
            if tab == .camera {
                return Color.white
            } else {
                return Color.black
            }
        } else if tabBarVM.current == tab {
            return Color.primary
        } else {
            return colorScheme.primaryReverse
        }
    }
    
}

//tabBarVM.current == tab ? .primary : colorScheme == .light ? .white : .black
