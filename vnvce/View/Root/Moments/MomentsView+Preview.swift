//
//  MomentsView+Preview.swift
//  vnvce
//
//  Created by Kerem Cesme on 9.11.2022.
//

import SwiftUI
import SwiftUIX
import PureSwiftUI

extension MomentsView {
    
    @ViewBuilder
    public var PreviewView: some View {
        if !momentsVM.viewIsReady || momentsVM.onDragging {
            Color.clear
                .overlay(alignment: previewImageAlignment) {
                    Image(uiImage: returnImage())
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(returnFrame())
                        .clipped()
                        .overlay(Blur)
                        .mask(RoundedRectangle(cornerRadius()))
                        .scaleEffect(returnScale(), anchor: .top)
                        .padding(.top, previewImageTopPadding)
                }
                .scaleEffect(momentsViewScaleEffect)
                .offset(momentsVM.viewOffset)
                .offsetToPositionIfNot(momentsVM.show, momentsVM.selectedMomentCellFrame.center)
                .ignoresSafeArea()
        }
    }
    
    @ViewBuilder
    private var Blur: some View {
        BlurView(style: momentsVM.blur)
            .opacity(!momentsVM.show || momentsVM.onDraggingAnimation ? 1 : 0.001)
    }
    
    private func cornerRadius() -> CGFloat {
        if UIDevice.current.hasNotch() {
            let screenWidth = UIScreen.main.bounds.width
            let cellWidth = momentsVM.selectedMomentCellSize.width
            let radius: CGFloat = 20
            let ratio = screenWidth / cellWidth
            return momentsVM.show ? radius / ratio : 0
        } else {
            return 0
        }
    }
    
    private func returnScale() -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let cellWidth = momentsVM.selectedMomentCellSize.width
        
        return momentsVM.show ? screenWidth / cellWidth : 1
    }
    
    private func returnScaleAnchor() -> UnitPoint {
        return momentsVM.show ? .top : .center
    }
    
    private func returnFrame() -> CGSize {
        let cellWidth = momentsVM.selectedMomentCellSize.width
        let cellHeight = momentsVM.selectedMomentCellSize.height
        return CGSize(width: cellWidth, height: momentsVM.show ? cellWidth * 16 / 9 : cellHeight)
    }
    
    private var momentsViewScaleEffect: CGFloat {
        if momentsVM.show {
            let screen = UIScreen.main.bounds
            let size = momentsVM.viewOffset
            
            let max = (screen.width + screen.height) / 2
            
            let width = size.width
            let height = size.height
            
            let widthAmount = abs(width < 0 ? 0 : width)
            let heightAmount = abs(height < 0 ? 0 : height)
            
            let currentAmount = widthAmount + heightAmount
            
            let percentage = currentAmount / max
            
            return 1.0 - min(percentage, 0.15)
        } else {
            return 1
        }
    }
    
    
    @ViewBuilder
    public var PreviewView2: some View {
        if !momentsVM.viewIsReady || momentsVM.onDragging {
            Color.clear.ignoresSafeArea()
                .overlay(alignment: previewImageAlignment) {
                    Image(uiImage: returnImage())
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(previewFrame())
                        .cornerRadius(momentsVM.show && UIDevice.current.hasNotch() ? 20 : 0)
                        .padding(previewImageTopPadding)
                }
                .scaleEffect(momentsViewScaleEffect)
                .offset(momentsVM.viewOffset)
                .offsetToPositionIfNot(momentsVM.show, momentsVM.selectedMomentCellFrame.center)
        }
    }
    
    private var previewImageAlignment: Alignment {
        switch momentsVM.show {
        case true:
            return .top
        case false:
            return .center
        }
    }
    
    private func returnImage() -> UIImage {
        
        guard let momentGroup = momentsVM.moments[safe: momentsVM.pageIndex] else {
            return UIImage()
        }
        if let image = momentGroup.moments[momentGroup.currentIndex].downloadedImage?.image {
            return image
        } else if let image = momentGroup.moments[momentGroup.currentIndex].thumbnailImage?.image {
            return image
        } else {
            return UIImage()
        }
    }

    private func previewFrame() -> CGSize {
        let width = UIScreen.main.bounds.width
        if UIDevice.current.hasNotch() {
            return CGSize(width: width, height: width * (momentsVM.show ? 16 / 9 : 3 / 2))
        } else {
            return CGSize(width: width, height: momentsVM.show ? UIScreen.main.bounds.height : (width * 3 / 2))
        }
    }
    
    private var previewImageTopPadding: CGFloat {
        if momentsVM.show && UIDevice.current.hasNotch() {
            return UIDevice.current.statusBarHeight()
        } else {
            return 0
        }
    }
    
    
}
