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
    
    private var relationship: Relationship?
    
    init(momentsVM: UserMomentsViewModel, momentsVM2: MomentsViewModel, relationship: Relationship? = .me) {
        self._momentsVM = StateObject(wrappedValue: momentsVM)
        self._momentsVM2 = StateObject(wrappedValue: momentsVM2)
        self.relationship = relationship
    }
    
    private var columns: [GridItem] = [
        GridItem(.adaptive(minimum: 80), spacing: 1, alignment: .leading),
        GridItem(.adaptive(minimum: 80), spacing: 1, alignment: .leading),
        GridItem(.adaptive(minimum: 80), spacing: 1, alignment: .leading),
    ]
    
    var body: some View {
        // NEW
        LazyVGrid(columns: columns, alignment: .leading, spacing: 1) {
//            ForEach(self.momentsVM2.moments, id: \.id) { moments in
//                Cell(moments)
//            }
            
            ForEach(Array(self.momentsVM2.moments.enumerated()), id: \.element.id) {
                MomentsGridCellView(self.$momentsVM2.moments[$0], index: $0).id($1.id)
            }
            
            
        }
//        GridLayout(items: momentsVM2.moments,
//                   id: \.id,
//                   spacing: 1,
//                   columnCount: 3,
//                   cellRatio: 3 / 2,
//                   content: Cell)
        
//        let items = momentsVM2.moments
//        let items2 = Array(momentsVM2.moments.enumerated())
//
//
//
//        ForEach(Array(momentsVM2.moments.enumerated()), id: \.element.id) { index, item in
//
//        }
        // OLD
//        GridLayout(items: momentsVM.momentsMain,
//                   id: \.id,
//                   spacing: 1,
//                   columnCount: 3,
//                   cellRatio: 3 / 2) { moments in
//            if let index = momentsVM.momentsMain.firstIndex(where: {$0 == moments}) {
//                MomentsGridCellView(moments: $momentsVM.momentsMain[index], index: index, momentsVM: momentsVM)
//            }
//
//        }
    }
    
    @ViewBuilder
    private func Cell(index: Int, _ moments: Binding<Moments>) -> some View {
//        GeometryReader {
//            let size = $0.size
//
//            if let moment = moments.moments[safe: moments.currentIndex] {
//
//            }
//
//            if let moment = moments.moments[safe: moments.currentIndex],
//               let index = self.momentsVM2.moments.firstIndex(where: {moments.id == $0.id}) {
//
//                if let uiImage = moment.thumbnailImage?.image {
//                    ImageView(uiImage, height: size.width * 3 / 2)
//                } else {
//                    LazyImage(url: moment.returnURL) {
//                        if let uiImage = $0.imageContainer?.image {
//                            ImageView(uiImage, height: size.width * 3 / 2)
//                                .onAppear {
//                                    let image = CodableImage(image: uiImage)
//                                    self.momentsVM2.moments[index].moments[moments.currentIndex].thumbnailImage = image
//                                }
//                        } else {
//                            Color.primary.opacity(0.05).shimmering()
//                        }
//                    }
//                    .animation(.default)
//                    .pipeline(.shared)
//                    .processors([ImageProcessors.Resize(width: size.width)])
//                    .priority(.veryHigh)
//                }
//            }
//        }
//        .clipped()
//        .aspectRatio(2 / 3, contentMode: .fit)
    }
    
    @ViewBuilder
    private func Cell2(_ moments: Moments) -> some View {
        GeometryReader {
            let size = $0.size
            
            if let moment = moments.moments[safe: moments.currentIndex],
               let index = self.momentsVM2.moments.firstIndex(where: {moments.id == $0.id}) {
                
                if let uiImage = moment.thumbnailImage?.image {
                    ImageView(uiImage, height: size.width * 3 / 2)
                } else {
                    LazyImage(url: moment.returnURL) {
                        if let uiImage = $0.imageContainer?.image {
                            ImageView(uiImage, height: size.width * 3 / 2)
                                .onAppear {
                                    let image = CodableImage(image: uiImage)
                                    self.momentsVM2.moments[index].moments[moments.currentIndex].thumbnailImage = image
                                }
                        } else {
                            Color.primary.opacity(0.05).shimmering()
                        }
                    }
                    .animation(.default)
                    .pipeline(.shared)
                    .processors([ImageProcessors.Resize(width: size.width)])
                    .priority(.veryHigh)
                }
            }
        }
        .clipped()
        .aspectRatio(2 / 3, contentMode: .fit)
    }
    
    @ViewBuilder
    private func ImageView(_ uiImage: UIImage, height: CGFloat) -> some View {
        Image(uiImage: uiImage)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .overlay(BlurView(style: .light))
            .frame(height: height)
//            .clipped()
            
    }
}

@MainActor
struct MomentsGridCellView: View {
    @Binding private var momentGroup: Moments
    
    private var index: Int
    
    init(_ momentGroup: Binding<Moments>, index: Int) {
        self._momentGroup = momentGroup
        self.index = index
    }
    
    private func onAppear(_ uiImage: UIImage) {
        let image = CodableImage(image: uiImage)
        self.momentGroup.moments[momentGroup.currentIndex].thumbnailImage = image
    }
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            if let moment = self.momentGroup.moments[safe: momentGroup.currentIndex] {
                ImageContainerView(moment, width: size.width)
            }
        }
        .clipped()
        .aspectRatio(2 / 3, contentMode: .fit)
    }
    
    @ViewBuilder
    private func ImageContainerView(_ moment: Moment, width: CGFloat) -> some View {
        let ratio: CGFloat = 3 / 2
        if let uiImage = moment.thumbnailImage?.image {
            ImageView(uiImage, height: width * ratio)
        } else {
            LazyImage(url: moment.returnURL) {
                if let uiImage = $0.imageContainer?.image {
                    ImageView(uiImage, height: width * ratio)
                        .onAppear { self.onAppear(uiImage) }
                } else {
                    Color.primary.opacity(0.05).shimmering()
                }
            }
            .animation(.default)
            .pipeline(.shared)
            .processors([ImageProcessors.Resize(width: width)])
            .priority(.veryHigh)
        }
    }
    
    @ViewBuilder
    private func ImageView(_ uiImage: UIImage, height: CGFloat) -> some View {
        Image(uiImage: uiImage)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .overlay(BlurView(style: .light))
            .frame(height: height)
    }
}
