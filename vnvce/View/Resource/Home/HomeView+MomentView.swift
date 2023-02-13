//
//  HomeView+MomentView.swift
//  vnvce
//
//  Created by Kerem Cesme on 26.01.2023.
//

import SwiftUI
import SwiftUIX
import PureSwiftUI

extension HomeView {
    @ViewBuilder
    public var MomentsView: some View {
        ForEach(Array(homeVM.testUsers.enumerated()), id: \.element.id, content: MomentView.init)
    }
    
    private struct MomentView: View {
        @EnvironmentObject private var homeVM: HomeViewModel
        
        private var inx: Int
        private var user: UserTestModel
        
        public init(_ inx: Int, _ user: UserTestModel) {
            self.inx = inx
            self.user = user
        }
        
        private func getScale(_ proxy: GeometryProxy) -> CGFloat {
            let minX = abs(proxy.frame(in: .global).minX)
            return abs(1 - minX / homeVM.momentSize.width / 4)
        }
        
        private func getOpacity(_ proxy: GeometryProxy) -> CGFloat {
            let minX = abs(proxy.frame(in: .global).minX)
            return 1 - minX / homeVM.momentSize.width * 1.5
        }
        
        private func getCornerRadius(_ proxy: GeometryProxy)  -> CGFloat {
            let minX = abs(proxy.frame(in: .global).minX)
            let radius = minX / 12.5
            return radius >= 25 ? 25 : radius
        }
        
        var body: some View {
            GeometryReader(content: _MomentView)
            .tag(user.id.uuidString)
        }
        
        @ViewBuilder
        private func _MomentView(_ proxy: GeometryProxy) -> some View {
            if UIDevice.current.hasNotch() {
                VStack(alignment: .leading, spacing: 10) {
                    NavigationTopLeading
                        .opacity(getOpacity(proxy))
                        .scaleEffect(getScale(proxy), anchor: .leading)
                    _MomentView
                        .cornerRadius(25, style: .continuous)
                        .scaleEffect(getScale(proxy))
                }
            } else {
                ZStack(alignment: .topLeading){
                    _MomentView
                    Group {
                        GradientForNoneNotch
                        NavigationTopLeading
                    }
                    .opacity(getOpacity(proxy))
                }
                .cornerRadius(getCornerRadius(proxy), style: .continuous)
                .scaleEffect(getScale(proxy))
                .ignoresSafeArea()
            }
            
        }
        
        @ViewBuilder
        private var _MomentView: some View {
            Image(user.moment)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(homeVM.momentSize)
        }
        
        @ViewBuilder
        private var NavigationTopLeading: some View {
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            } label: {
                HStack(spacing: 10){
                    ProfilePicture
                    Text(user.name)
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .medium, design: .default))
                    Spacer()
                }
                .frame(height: homeVM.navBarHeight)
            }
            .buttonStyle(ScaledButtonStyle())
            .padding(.horizontal, 20)
            .padding(.top, !UIDevice.current.hasNotch() ? UIDevice.current.statusBarHeight() + 4 : 0)
        }
        
        @ViewBuilder
        private var GradientForNoneNotch: some View {
            LinearGradient(colors: [.black.opacity(0.5), .clear], startPoint: .top, endPoint: .bottom)
                .frame(height: UIDevice.current.statusBarHeight() + homeVM.navBarHeight + 10)
        }
        
        @ViewBuilder
        private var ProfilePicture: some View {
            ZStack {
                Group {
                    Image(user.picture)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(homeVM.navBarHeight - 1)
                    BlurView(style: .dark)
                        .frame(homeVM.navBarHeight)
                    Image(user.picture)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(homeVM.navBarHeight - 5)
                }
                .clipShape(Circle())
            }
        }
        
    }
}
