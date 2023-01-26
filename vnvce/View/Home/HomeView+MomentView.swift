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
        
        var body: some View {
            GeometryReader(content: _MomentView)
            .tag(user.id.uuidString)
        }
        
        @ViewBuilder
        private func _MomentView(_ proxy: GeometryProxy) -> some View {
            VStack(alignment: .leading, spacing: 10) {
                NavigationTopLeading
                    .opacity(getOpacity(proxy))
                    .scaleEffect(getScale(proxy), anchor: .leading)
                _MomentView
                    .scaleEffect(getScale(proxy))
            }
        }
        
        @ViewBuilder
        private var _MomentView: some View {
            Image(user.moment)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(homeVM.momentSize)
                .cornerRadius(25, style: .continuous)
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
