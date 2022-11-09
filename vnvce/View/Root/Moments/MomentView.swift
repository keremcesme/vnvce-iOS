//
//  MomentView.swift
//  vnvce
//
//  Created by Kerem Cesme on 9.11.2022.
//

import SwiftUI
import SwiftUIX
import PureSwiftUI

struct MomentView: View {
    @StateObject public var momentsVM: MomentsViewModel
    
    @Binding private var moment: Moment
    @Binding private var moments: Moments
    
    init(
        moment: Binding<Moment>,
        moments: Binding<Moments>,
        vm: MomentsViewModel
    ) {
        self._moment = moment
        self._moments = moments
        self._momentsVM = StateObject(wrappedValue: vm)
    }
    
    private func topPadding() -> CGFloat {
        return UIDevice.current.hasNotch() ? UIDevice.current.statusBarHeight() : 0
    }
    
    var body: some View {
        
        VStack {
            ImageView
                .frame(imageFrame())
                .cornerRadius(UIDevice.current.hasNotch() ? 20 : 0)
                .padding(.top, topPadding())
                .opacity(momentsVM.onDragging || !momentsVM.viewIsReady ? 0.00001 : 1)
                .onTapGesture {
                    self.momentsVM.dismissNonAsync()
                }
            
            if UIDevice.current.hasNotch() {
                Text("TEST")
                    .foregroundColor(.white)
                    .font(.title2)
                    .padding()
                    .background(Color.blue)
                    .clipShape(Capsule())
                    .opacity(momentsVM.onDraggingAnimation || !momentsVM.show ? 0.0001 : 1)
            }
        }
        
        
        
        //                .onTapGesture {
        //                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        //                    if let index = self.momentsVM.moments.firstIndex(where: {$0.id == self.moments.id }) {
        //                        if self.momentsVM.moments.count == 1 {
        //                            Task {
        //                                await self.momentsVM.dismiss()
        //                                self.momentsVM.moments.remove(at: index)
        //                            }
        //                        } else {
        //                            self.momentsVM.pageIndex = index - 1
        //                            self.momentsVM.moments.remove(at: index)
        //                        }
        //                    }
        //                }
    }
    
    @ViewBuilder
    private var ImageView: some View {
        if let image = returnImage() {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            Color.white.opacity(0.1).shimmering()
        }
    }
    
    private func returnImage() -> UIImage? {
        if let image = self.moment.downloadedImage?.image {
            return image
        } else if let image = self.moment.thumbnailImage?.image {
            return image
        } else {
            return nil
        }
    }
    
    private func imageFrame() -> CGSize {
        let width = UIScreen.main.bounds.width
        if UIDevice.current.hasNotch() {
            return CGSize(width, width * 16 / 9)
        } else {
            let height = UIScreen.main.bounds.height
            return CGSize(width, height)
        }
    }
}
