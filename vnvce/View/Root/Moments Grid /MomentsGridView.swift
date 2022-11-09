//
//  UserMomentsView.swift
//  vnvce
//
//  Created by Kerem Cesme on 31.10.2022.
//

import SwiftUI
import SwiftUIX
import PureSwiftUI
import Nuke
import NukeUI

struct MomentsGridView: View {
    @EnvironmentObject private var currentUserVM: CurrentUserViewModel
    
    @StateObject private var momentsVM: UserMomentsViewModel
    @StateObject private var momentsVM2: MomentsViewModel
    
    private let proxy: ScrollViewProxy
    
    private var relationship: Relationship?
    
    init(proxy: ScrollViewProxy, momentsVM: UserMomentsViewModel, momentsVM2: MomentsViewModel, relationship: Relationship? = .me) {
        self.proxy = proxy
        self._momentsVM = StateObject(wrappedValue: momentsVM)
        self._momentsVM2 = StateObject(wrappedValue: momentsVM2)
        self.relationship = relationship
    }
    
    private var columns: [GridItem] = [
        GridItem(.adaptive(minimum: 80), spacing: 1, alignment: .leading),
        GridItem(.adaptive(minimum: 80), spacing: 1, alignment: .leading),
        GridItem(.adaptive(minimum: 80), spacing: 1, alignment: .leading)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 1, content: GridItems)
    }
    
    @ViewBuilder
    private func GridItems() -> some View {
        ForEach(Array(self.momentsVM2.moments.enumerated()), id: \.element.id, content: GridCell)
    }
    
    @ViewBuilder
    private func GridCell(_ inx: Int, _ item: Moments) -> some View {
        MomentsGridCellView(
            momentGroup: self.$momentsVM2.moments[inx],
            index: inx,
            proxy: self.proxy,
            vm: momentsVM2)
        .id(item.id)
    }
}

//@MainActor
struct MomentsGridCellView: View {
    @StateObject private var momentsVM: MomentsViewModel
    
    @Binding private var momentGroup: Moments
    
    private var index: Int
    private let proxy: ScrollViewProxy
    
    init(momentGroup: Binding<Moments>, index: Int, proxy: ScrollViewProxy, vm: MomentsViewModel) {
        self._momentGroup = momentGroup
        self.index = index
        self.proxy = proxy
        self._momentsVM = StateObject(wrappedValue: vm)
    }
    
    private let ratio: CGFloat = 3 / 2
    
    // MARK: Functions -
    private func onAppear(_ uiImage: UIImage) {
        let image = CodableImage(image: uiImage)
        self.momentGroup.moments[momentGroup.currentIndex].thumbnailImage = image
    }
    
    private func onChangeViewIsReady(_ value: Bool, _ size: CGSize, _ frame: CGRect) {
        if !value && self.index == self.momentsVM.pageIndex {
            self.momentsVM.onChangeViewIsReady(size: size, frame: frame)
        }
    }
    
    private func onChangePageIndex(_ value: Int) {
        if value == self.index && self.momentsVM.viewIsReady {
            self.proxy.scrollTo(self.momentGroup.id, anchor: .bottom)
        }
    }
    
    // MARK: View -
    var body: some View {
        GeometryReader(content: CellView)
            .clipped()
            .aspectRatio(2 / 3, contentMode: .fit)
            .opacity(momentsVM.pageIndex == index && momentsVM.viewWillAppear ? 0.001 : 1)
            .onChange(of: momentsVM.pageIndex, perform: onChangePageIndex)
        
    }
    
    // MARK: Subviews -
    @ViewBuilder
    private func CellView(_ g: GeometryProxy) -> some View {
        if let moment = self.momentGroup.moments[safe: momentGroup.currentIndex] {
            ImageContainerView(moment, width: g.size.width)
                .contentShape(Rectangle())
                .onTapGesture {
                    await self.momentsVM.gridCellTapAction(
                        index: index,
                        size: g.size,
                        frame: g.frame(in: .global))
                    try? await Task.sleep(seconds: self.momentsVM.animationDuration)
                    await self.proxy.scrollTo(momentGroup.id, anchor: .bottom)
                }
                .onChange(of: momentsVM.viewIsReady) {
                    onChangeViewIsReady($0, g.size, g.frame(in: .global))
                }
        }
    }
    
    @ViewBuilder
    private func ImageContainerView(_ moment: Moment, width: CGFloat) -> some View {
        if let uiImage = moment.thumbnailImage?.image {
            ImageView(uiImage, height: width * ratio)
        } else {
            LazyImage(url: moment.returnURL, content: LazyImageView)
                .animation(nil)
                .pipeline(.shared)
                .processors([ImageProcessors.Resize(width: width)])
                .priority(.veryHigh)
        }
    }
    
    @ViewBuilder
    private func LazyImageView(_ state: LazyImageState) -> some View {
        if let uiImage = state.imageContainer?.image {
            ImageView(uiImage, height: uiImage.size.width * ratio)
                .onAppear { self.onAppear(uiImage) }
        } else {
            Color.primary.opacity(0.05).shimmering()
        }
    }
    
    @ViewBuilder
    private func ImageView(_ uiImage: UIImage, height: CGFloat) -> some View {
        Image(uiImage: uiImage)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .overlay(BlurView(style: momentsVM.blur))
            .frame(height: height)
    }
}
