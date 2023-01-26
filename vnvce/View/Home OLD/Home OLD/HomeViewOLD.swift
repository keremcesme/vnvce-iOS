//
//  HomeViewOLD.swift
//  vnvce
//
//  Created by Kerem Cesme on 6.11.2022.
//

import SwiftUI
import SwiftUIX
import PureSwiftUI
import Nuke
import NukeUI
import Colorful

struct HomeViewOLD: View {
    @Environment(\.viewController) public var viewControllerHolder: ViewControllerHolder
    
    @EnvironmentObject public var rootVM: RootViewModel
    @EnvironmentObject public var currentUserVM: CurrentUserViewModelOLD
    @EnvironmentObject public var searchVM: SearchViewModelOLD
    @EnvironmentObject public var camera: CameraManager
    
    var body: some View {
            NavigationView {
                ZStack {
//                    ColorfulView()
//                        .colorScheme(.dark)
//                        .overlay(Color.black.opacity(0.5))
//                        .ignoresSafeArea()
                    Color.black
                        .frame(UIScreen.main.bounds.size)
                        .ignoresSafeArea()
                    if UIDevice.current.hasNotch() {
                        VStack(spacing:15) {
                            CameraViewUI()
                            BottomView
                            Spacer()
                        }
                    } else {
                        CameraViewUI()
                            .overlay(alignment: .bottom) {
                                LinearGradient(colors: [.clear, .black.opacity(0.5)], startPoint: .top, endPoint: .bottom)
                                    .frame(height: 80)
                            }
                            .overlay(alignment: .bottom) {
                                BottomView
                                    .padding(.bottom, 15)
                            }
                    }
                    
                }
                .ignoresSafeArea()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(ToolBar)
            }
            .overlay {
                ZStack {
                    EmptyView()
                    if searchVM.show {
                        Color.black
                    }
                }
            }
            .frame(UIScreen.main.bounds.size)
    }
    
    @ViewBuilder
    private var BottomView: some View {
        GeometryReader {
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 15) {
                        ShutterView()
                        ForEach((1...24), id: \.self){ item in
                            Button {
                                withAnimation {
                                    proxy.scrollTo(item, anchor: .trailing)
                                }
                            } label: {
                                RoundedRectangle(15, style: .continuous)
                                    .foregroundColor(.white)
                                    .frame(70, 70)
//                                    .opacity(0.1)
                                    .overlay {
                                        Text("\(item)")
                                            .foregroundColor(.white)
                                            .font(.title.bold())
                                    }
                            }
                            .buttonStyle(.plain)
                            .id(item)
                        }
                    }
                    .padding(.trailing, 15)
                    .padding(.leading, UIScreen.main.bounds.width / 2 - 40)
                }
            }
            .frame($0.size)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        
    }
    
    @ViewBuilder
    private var TestView: some View {
        ZStack(alignment: .leading) {
            GeometryReader { g in
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 15) {
                            ForEach((1...24), id: \.self){ item in
                                Button {
                                    withAnimation {
                                        proxy.scrollTo(item, anchor: .trailing)
                                    }
                                } label: {
                                    RoundedRectangle(15, style: .continuous)
                                        .foregroundColor(.white)
                                        .frame(70, 70)
                                        .opacity(0.1)
                                        .overlay {
                                            Text("\(item)")
                                                .foregroundColor(.white)
                                                .font(.title.bold())
                                        }
                                }
                                .buttonStyle(.plain)
                                .id(item)
                            }
                        }
                        .padding(.leading, 80)
                        .padding(.horizontal, 15)
                    }
                }
                
            }
            .frame(maxWidth: .infinity)
            .frame(height: 70)
            .cornerRadius(100, corners: .topLeft)
            .cornerRadius(100, corners: .bottomLeft)
            ShutterView()
        }
        .padding(.leading, 15)
    }
    
}


