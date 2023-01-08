//
//  FeedView.swift
//  vnvce
//
//  Created by Kerem Cesme on 15.11.2022.
//

import SwiftUI
import SwiftUIX
import PureSwiftUI
import Introspect
import Nuke
import NukeUI

struct FeedView: View {
    @Environment(\.viewController) public var viewControllerHolder: ViewControllerHolder
    
    @EnvironmentObject public var feedVM: FeedViewModel
    
    @EnvironmentObject public var currentUserVM: CurrentUserViewModel
    @EnvironmentObject public var camera: CameraManager
    @EnvironmentObject public var searchVM: SearchViewModel
    
    
    var body: some View {
        GeometryReader(content: Content)
            .ignoresSafeArea()
    }
    
    @ViewBuilder
    private func Content(_ proxy: GeometryProxy) -> some View {
        ZStack(alignment: .top) {
            Color.black
            switch UIDevice.current.hasNotch() {
            case true: _NotchView
            case false: _NormalView
            }
        }
        .taskInit(feedVM.fetch)
    }
    
    @ViewBuilder
    private var _NotchView: some View {
        VStack(spacing: 15) {
            PageView
                .overlay(NavigationBar, alignment: .top)
            BottomView
        }
    }
    
    @ViewBuilder
    private var _NormalView: some View {
        PageView
            .overlay(BottomView, alignment: .bottom)
    }
    
    private func offsetTask(_ value: CGFloat) {
        DispatchQueue.main.async {
            let screenWidth = UIScreen.main.bounds.width
            let absValue = abs(value)
            self.feedVM.pageIndex = Int(round(absValue / screenWidth))
        }
    }
    
    @ViewBuilder
    private var PageView: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 0) {
                    CameraView()
                        .id(-1)
                    let width = UIScreen.main.bounds.width
                    let height = width * 16 / 9
                    
                    
                    
                    ForEach(feedVM.testData, id: \.self) { item in
                        let url = URL(string: "https://picsum.photos/id/\(item + 10)/1080/1920")
                        
                        LazyImage(url: url) { state in
                            if let uiImage = state.imageContainer?.image {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: width, height: height)
                                    .clipped()
                            } else {
                                Color.white
                                    .opacity(0.1)
                                    .frame(width: width, height: height)
                                    .shimmering()
                            }
                        }
                        .overlay {
                            Text("\(item)")
                                .foregroundColor(.white)
                                .font(.title.bold())
                                .shadow(4)
                        }
                        .id(feedVM.findIndex(item: item))
                    }
                }
                .introspectScrollView(customize: feedVM.momentsScrollViewConnector)
                .offsetX(offsetTask)
            }
        }
        .frame(camera.previewViewFrame())
        .cornerRadius(UIDevice.current.hasNotch() ? 15 : 0, corners: [.bottomRight, .bottomLeft])
    }
    
    
    @ViewBuilder
    private var BottomView: some View {
        GeometryReader {
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ShutterView()
                            .id(-1)
                        UsersView
                    }
                    .padding(.trailing, UIScreen.main.bounds.width / 2 - 35)
                    .padding(.leading, UIScreen.main.bounds.width / 2 - 40)
                }
                .onChange(of: feedVM.pageIndex) { id in
                    withAnimation {
                        proxy.scrollTo(id, anchor: .center)
                    }
                }
            }
            .frame($0.size)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 80)
    }
    
    @ViewBuilder
    private var UsersView: some View {
        ForEach(Array(feedVM.data.enumerated()), id: \.element.id){ index, item in
            Button {
//                feedVM.pageIndex = item
//                feedVM
//                    .momentsScrollView
//                    .setContentOffset(
//                        CGPoint(x: feedVM.scrollTo(id: feedVM.findIndex(item: item)), y: 0),
//                        animated: false)
//
            } label: {
                let url = URL(string: "https://xsgames.co/randomusers/avatar.php?g=female")
                LazyImage(url: url) { state in
                    if let uiImage = state.imageContainer?.image {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(feedVM.pageIndex == Int(item.id) ? 80 : 70)
                            .clipped()
                            .cornerRadius(15, style: .continuous)
                    } else {
                        RoundedRectangle(15, style: .continuous)
                            .foregroundColor(.white)
                            .opacity(0.1)
                            .frame(feedVM.pageIndex == Int(item.id) ? 80 : 70)
                            .shimmering()
                    }
                }
                .overlay {
                    Text("\(item.id)")
                        .foregroundColor(.black)
                        .font(.title.bold())
                }
                .animation(.default, value: feedVM.pageIndex)
            }
            .buttonStyle(.plain)
            .id(Int(item.id))
        }
    }
    
}
