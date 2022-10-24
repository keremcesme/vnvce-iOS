//
//  TabBarOLD.swift
//  vnvce
//
//  Created by Kerem Cesme on 7.09.2022.
//

import SwiftUI
import SwiftUIX
import PureSwiftUI

struct TabBarOLD: View {
    @EnvironmentObject var tabBarVM: TabBarViewModel
    @EnvironmentObject var uploadPostVM: UploadPostViewModel
    @EnvironmentObject var cameraVM: CameraViewModel
    
    var body: some View {
        VStack {
            Spacer()
            TabBar
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
    
    @ViewBuilder
    private var TabBar: some View {
        GeometryReader { g in
            let height = g.size.height
            HStack(spacing: 0){
                TabBarItem(.feed, height: height)
                ShareButton(height: height)
                TabBarItem(.profile, height: height)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 60)
        .background(Background)
        .padding(.horizontal, 20)
        .padding(.bottom, UIDevice.current.hasNotch() ? 0 : 15)
    }
    
    @ViewBuilder
    private var Background: some View {
        BlurView(style: .systemUltraThinMaterial)
            .clipShape(Capsule())
    }
    
    @ViewBuilder
    private func TabBarItem(_ tab: Tab, height: CGFloat) -> some View {
        Button {
            tabBarVM.current = tab
        } label: {
            GeometryReader{g in
                ZStack{
                    Color.primary.opacity(0.00001)
                    Image(tab.name)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .foregroundColor(Color.primary)
                        .opacity(tabBarVM.current == tab ? 1 : 0.15)
                        .frame(width: 22, height: 22, alignment: .center)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: height)
        }
        .buttonStyle(PlainButtonStyle())

    }
    
    @ViewBuilder
    private func ShareButton(height: CGFloat) -> some View {
        GeometryReader {
            let frame = $0.frame(in: .global)
            let size = $0.size
            
            AsyncButton {
                await cameraVM.openCamera(frame, size)
            } label: {
                ZStack{
                    Color.primary.opacity(0.00001)
                        .frame(width: height, height: height)
                    Circle()
                        .foregroundColor(.primary)
                        .frame(width: height - 6, height: height - 6)
                        .mask(
                            Circle()
                                .overlay(
                                    Image(systemName: "plus")
                                        .font(.system(size: 24, weight: .medium, design: .rounded))
                                        .blendMode(.destinationOut)
                                )
                        )
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .frame(width: height, height: height, alignment: .center)
        
//        Button {
//            DispatchQueue.main.async {
//                uploadPostVM.showUploadPostView = true
//            }
//        } label: {
//            GeometryReader{ g in
//                ZStack{
//                    Color.primary.opacity(0.00001)
//                        .frame(width: height, height: height)
//                    Circle()
//                        .foregroundColor(.primary)
//                        .frame(width: height - 6, height: height - 6)
//                        .mask(
//                            Circle()
//                                .overlay(
//                                    Image(systemName: "plus")
//                                        .font(.system(size: 24, weight: .medium, design: .rounded))
//                                        .blendMode(.destinationOut)
//                                )
//                        )
//                }
//            }
//            .frame(width: height, height: height, alignment: .center)
//        }
//        .buttonStyle(PlainButtonStyle())
//        .fullScreenCover(isPresented: $uploadPostVM.showUploadPostView) {
//            PostImagePickerView()
//        }
    }
            
    
}
