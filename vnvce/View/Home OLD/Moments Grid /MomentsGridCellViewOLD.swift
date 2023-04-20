//
//  MomentsGridCellViewOLD.swift
//  vnvce
//
//  Created by Kerem Cesme on 31.10.2022.
//

import SwiftUI
import SwiftUIX
import PureSwiftUI
import Nuke
import NukeUI

struct MomentsGridCellViewOLD: View {
    @StateObject private var momentsVM: UserMomentsViewModelOLD
    
    @Binding private var moments: Moments
    
    private var index: Int
    
    init(moments: Binding<Moments>, index: Int, momentsVM: UserMomentsViewModelOLD) {
        self._moments = moments
        self.index = index
        self._momentsVM = StateObject(wrappedValue: momentsVM)
    }
    
    var body: some View { Cell }
    
    @ViewBuilder
    private var Cell: some View {
        GeometryReader {
            let frame = $0.frame(in: .global)
            let size = $0.size
            
            let momentIndex = self.moments.currentIndex
            let moment = self.moments.moments[momentIndex]
            
            ImageContainer(moment: moment, size: size, frame: frame, index: momentIndex)
//            if let moment = moments.moments[moments.currentIndex],
//               let index = moments.moments.firstIndex(where: { $0 == moment }){
//                ImageContainer(moment: moment, size: size, frame: frame, index: index)
//            }
        }
    }
    
    @ViewBuilder
    private func ImageContainer(moment: Moment, size: CGSize, frame: CGRect, index: Int) -> some View {
        LazyImage(url: moment.returnURL) {
            if let uiImage = $0.imageContainer?.image {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(size)
                    .clipped()
                    .overlay(BlurView(style: .light))
                    .overlay(DayLabel, alignment: .topTrailing)
                    .overlay(CountLabel, alignment: .bottomTrailing)
                    .opacity((momentsVM.selectedMomentDayIndex == self.index && momentsVM.momentsViewWillAppear) ? 0.0001 : 1)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        Task {
                            await momentsVM.momentCellTapAction(id: self.moments.id, index: self.index, size: size, frame: frame)
                        }
                    }
//                    .onTapGesture {
//                        Task {
//                            await self.momentsVM.tapMomentAction(
//                                moment: moment,
//                                index: self.index,
//                                image: uiImage,
//                                size: size,
//                                frame: frame)
//                        }
//                    }
                    .onAppear {
                        let currentIndex = self.moments.currentIndex
                        if self.moments.moments[currentIndex].thumbnailImage == nil {
                            let image = CodableImage(image: uiImage)
                            self.moments.moments[currentIndex].thumbnailImage = image
                        }
                        
//                        if self.moments.currentIndex == self.index && self.moments.moments[self.index].thumbnailImage == nil {
//                            self.moments.moments[self.index].thumbnailImage = CodableImage(image: uiImage)
//                        }
                        
//                        if self.moments.first?.thumbnailImage == nil {
//                            self.moments[0].thumbnailImage = CodableImage(image: uiImage)
//                        }
                    }
                    .onChange(of: momentsVM.momentsViewIsReady) { value in
                        if !value && self.index == momentsVM.currentIndex {
                            self.momentsVM.onChangeIndexUpdateCell(size: size, frame: frame)
                        }
                    }
                    .onChange(of: momentsVM.currentIndex) { newIndex in
                        if self.index == newIndex {
                            self.momentsVM.onChangeIndexUpdateCurrentMoment(id: self.moments.id)
                        }
                    }
            } else {
                Color.primary.opacity(0.05).shimmering()
            }
        }
//        .animation(nil)
//        .pipeline(.shared)
//        .processors([ImageProcessors.Resize(width: size.width)])
//        .priority(.veryHigh)
    }
    
    @ViewBuilder
    private var DayLabel: some View {
        Text("\(moments.day)")
            .foregroundColor(.white)
            .font(.system(size: 20, weight: .semibold, design: .default))
            .shadow(radius: 4)
            .padding(5)
    }
    
    @ViewBuilder
    private var CountLabel: some View {
        if moments.count > 1 {
            RoundedRectangle(5, style: .continuous)
                .fill(.white)
                .shadow(radius: 4)
                .frame(width: 15, height: 15)
                .overlay {
                    if moments.count > 9 {
                        Text("9+")
                            .foregroundColor(.black)
                            .font(.system(size: 8, weight: .semibold, design: .default))
                    } else {
                        Text("\(moments.count)")
                            .foregroundColor(.black)
                            .font(.system(size: 9, weight: .semibold, design: .default))
                    }
                    
                }
                .padding(5)
        }
    }
    
    
    
}
