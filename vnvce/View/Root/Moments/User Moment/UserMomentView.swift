//
//  UserMomentView.swift
//  vnvce
//
//  Created by Kerem Cesme on 4.11.2022.
//

import SwiftUI
import SwiftUIX
import PureSwiftUI

struct UserMomentView: View {
    @StateObject public var momentsVM: UserMomentsViewModel
    
    public let size: CGSize
    
    @Binding private var moment: Moment
    private var momentsDayIndex: Int
    
    init(
        size: CGSize,
        moment: Binding<Moment>,
        momentsDayIndex: Int,
        momentsVM: UserMomentsViewModel
    ) {
        self.size = size
        self._moment = moment
        self.momentsDayIndex = momentsDayIndex
        self._momentsVM = StateObject(wrappedValue: momentsVM)
    }
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            VStack {
                Group {
                    if let image = self.moment.downloadedImage?.image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .onTapGesture {
                                self.momentsVM.momentsMain.remove(at: self.momentsDayIndex)
//                                if let index = self.momentsVM.momentsMain[self.momentsDayIndex].moments.firstIndex(where: { $0 == self.moment}) {
//                                    self.momentsVM.momentsMain[self.momentsDayIndex].moments.remove(at: index)
//                                }
                            }
                    } else if let image = self.moment.thumbnailImage?.image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Color.white.opacity(0.1)
                    }
                }
                .frame(width: size.width, height: UIDevice.current.hasNotch() ? size.width * 16 / 9 : size.height)
                .cornerRadius(UIDevice.current.hasNotch() ? 20 : 0)
                .padding(.top, UIDevice.current.hasNotch() ? UIDevice.current.statusBarHeight() : 0)
                .opacity(momentsVM.momentsViewIsReady ? 1 : 0.0001)
                .overlay(alignment: .bottom) {
                    if !UIDevice.current.hasNotch() {
                        Text("Next Moment")
                            .font(.title.bold())
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.blue)
                            .onTapGesture {
                                let moments = self.momentsVM.momentsMain[self.momentsDayIndex]
                                let count = moments.moments.count
                                
        //                        let count = self.momentsVM.moments[self.momentsDayIndex].count
        //                        self.momentsDayVM.nextMoment(count: count)
                                
                                DispatchQueue.main.async {
                                    let maxIndex = count - 1
                                    if moments.currentIndex < maxIndex {
                                        self.momentsVM.momentsMain[self.momentsDayIndex].currentIndex += 1
                                    } else {
                                        // Dismiss

                                    }
                                }
                                
                            }
                    }
                    
                }
                
                
//                Color.red
//                    .frame(width: size.width, height: size.width * 16 / 9)
//                    .cornerRadius(15)
//                    .overlay {
//                        Text("\(self.moment.id)")
//                            .foregroundColor(.black)
//                            .font(.title.bold())
//                    }
                    
                if UIDevice.current.hasNotch() {
                    Text("Next Moment")
                        .font(.title.bold())
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.blue)
                        .onTapGesture {
                            let moments = self.momentsVM.momentsMain[self.momentsDayIndex]
                            let count = moments.moments.count
                            
    //                        let count = self.momentsVM.moments[self.momentsDayIndex].count
    //                        self.momentsDayVM.nextMoment(count: count)
                            
                            DispatchQueue.main.async {
                                let maxIndex = count - 1
                                if moments.currentIndex < maxIndex {
                                    self.momentsVM.momentsMain[self.momentsDayIndex].currentIndex += 1
                                } else {
                                    // Dismiss

                                }
                            }
                            
                        }
                }
            }
            
            
        }
        .frame(size)
        .ignoresSafeArea()
    }
}
