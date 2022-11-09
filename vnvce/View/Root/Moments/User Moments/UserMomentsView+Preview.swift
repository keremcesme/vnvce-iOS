//
//  MomentView+Preview.swift
//  vnvce
//
//  Created by Kerem Cesme on 31.10.2022.
//

import SwiftUI
import PureSwiftUI

extension UserMomentsView {
    
    private var previewImageAlignment: Alignment {
        switch momentsVM.openMomentsView {
        case true:
            return .top
        case false:
            return .center
        }
    }
    
    private var previewImageTopPadding: CGFloat {
        if momentsVM.openMomentsView && UIDevice.current.hasNotch() {
            return UIDevice.current.statusBarHeight()
        } else {
            return 0
        }
    }
    
    @ViewBuilder
    public var PreviewView: some View {
        if !momentsVM.momentsViewIsReady {
            Color.clear.ignoresSafeArea()
                .overlay(alignment: previewImageAlignment) {
                    Image(uiImage: returnImage())
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(momentFrame5())
                        .overlay{
                            BlurView(style: .light)
                                .opacity(momentsVM.openMomentsView ? 0.00001 : 1)
                        }
                        .cornerRadius(momentsVM.openMomentsView && UIDevice.current.hasNotch() ? 20 : 0)
                        .padding(previewImageTopPadding)
                }
                
//            Color.clear
////                .frame(momentFrame3())
//                .overlay(alignment: previewImageAlignment) {
//                    Image(uiImage: momentsVM.selectedMomentDayImage)
//                        .resizable()
//                        .aspectRatio(contentMode: .fill)
//                        .frame(momentFrame4())
//                        .cornerRadius(momentsVM.isReadySelectedMomentDay ? 15 : 0)
////                        .overlay{
////                            BlurView(style: .light)
////                                .opacity(momentsVM.showSelectedMomentDay ? 0.00001 : 1)
////                        }
//                        .padding(previewImageTopPadding)
//                        .scaleEffect(previewScale())
//                }
            
        }
    }
    
    private func returnImage() -> UIImage {
        let momentDay = self.momentsVM.momentsMain[self.momentsVM.selectedMomentDayIndex]
        if let image = momentDay.moments[momentDay.currentIndex].downloadedImage?.image {
            return image
        } else if let image = momentDay.moments[momentDay.currentIndex].thumbnailImage?.image {
            return image
        } else {
            return UIImage()
        }
        
        
        
//        if let image = self.momentsVM.selectedMoment?.downloadedImage?.image {
//            return image
//        } else {
//            return momentsVM.selectedMomentDayImage
//        }
    }
    
    @ViewBuilder
    private var PreviewDayLabel: some View {
        EmptyView()
//        if let momentDay = momentsVM.selectedMomentDay {
//            Text("\(momentDay.day)")
//                .foregroundColor(.white)
//                .font(.system(size: 20, weight: .semibold, design: .default))
//                .shadow(radius: 4)
//                .padding(5)
//                .opacity(momentsVM.showSelectedMomentDay ? 0.00001 : 1)
//        }
    }
    
    @ViewBuilder
    private var PreviewCountLabel: some View {
        Text("asdf")
//        let count = self.momentsVM.moments[self.momentsVM.selectedMomentIndex].count
//        if count > 1 {
//            RoundedRectangle(5, style: .continuous)
//                .fill(.white)
//                .shadow(radius: 4)
//                .frame(width: 15, height: 15)
//                .overlay {
//                    if count > 9 {
//                        Text("9+")
//                            .foregroundColor(.black)
//                            .font(.system(size: 8, weight: .semibold, design: .default))
//                    } else {
//                        Text("\(count)")
//                            .foregroundColor(.black)
//                            .font(.system(size: 9, weight: .semibold, design: .default))
//                    }
//                    
//                }
//                .padding(5)
//                .opacity(momentsVM.showSelectedMomentDay ? 0.00001 : 1)
//        }
    }
    
//    private func previewScale() -> CGFloat {
//        if !momentsVM.showSelectedMomentDay {
//            let width = momentsVM.selectedMomentDaySize.width
//            let screenWidth = UIScreen.main.bounds.width
//            return screenWidth / width
//        } else {
//            return 1
//        }
//    }
    
//    private func momentFrame() -> CGSize {
//        let width = momentsVM.selectedMomentDaySize.width
////        return CGSize(width, width * 16 / 9)
//        return CGSize(width: width, height: width * (momentsVM.showSelectedMomentDay ? 16 / 9 : 3 / 2))
//    }
//
//    private func momentFrame2() -> CGSize {
//        let width = momentsVM.selectedMomentDaySize.width
//        return CGSize(width, width * 3 / 2)
//    }
//
//    private func momentFrame3() -> CGSize {
//        let width = UIScreen.main.bounds.width
//        return CGSize(width: width, height: width * (momentsVM.showSelectedMomentDay ? 16 / 9 : 3 / 2))
//    }
//
//    private func momentFrame4() -> CGSize {
//        let momentWidth = momentsVM.selectedMomentDaySize.width
//        let screenWidth = UIScreen.main.bounds.width
//        if momentsVM.showSelectedMomentDay {
//            return CGSize(width: screenWidth, height: screenWidth * 16 / 9)
//        } else {
//            return CGSize(width: momentWidth, height: momentWidth * 3 / 2)
//        }
//    }
    
    private func momentFrame5() -> CGSize {
        let width = UIScreen.main.bounds.width
        if UIDevice.current.hasNotch() {
            return CGSize(width: width, height: width * (momentsVM.openMomentsView ? 16 / 9 : 3 / 2))
        } else {
            return CGSize(width: width, height: momentsVM.openMomentsView ? UIScreen.main.bounds.height : (width * 3 / 2))
        }
    }
}
