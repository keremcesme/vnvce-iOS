//
//  PostView+Properties+BottomBar.swift
//  vnvce
//
//  Created by Kerem Cesme on 6.10.2022.
//

import SwiftUI

extension PostView.PostProperties {
    
    public var bottomBarAlignment: Alignment {
        switch postsVM.selectedPost.show {
        case true:
            return .bottom
        case false:
            return .center
        }
    }
    
    @ViewBuilder
    public var BottomBar: some View {
        HStack {
            
        }
    }
    
    @ViewBuilder
    public var TimerView: some View {
        HStack(spacing: 8){
            TimerEmojiProgress
            TimerTimeLabel
            Spacer()
            TimerControlButton
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .padding(.trailing, 4)
        .background(Color.primary)
        .clipShape(Capsule())
        .padding(.horizontal, 100)
        .padding(.bottom, UIDevice.current.postTimerBarBottomPadding)
        .opacity(postsVM.selectedPost.show ? 1 : 0.00001)
        .onChange(of: postsVM.selectedPost.ready) {
            if $0 {
                postVM.startTimer()
            }
        }
        .onChange(of: postVM.secondsElapsed) { value in
            print(String(format: "%0.1fs", postVM.secondsElapsed))
            DispatchQueue.main.async {
                if value > postVM.maxDuration - 0.2 {
                    self.postVM.maxDuration += 5.0
                    self.postVM.secondsElapsed = 0.0
                }
            }
        }
//        .onChange(of: postVM.onDragging) { value in
//            if value {
//                postVM.pauseTimer()
//            } else {
//                postVM.startTimer()
//            }
//        }
    }
    
    @ViewBuilder
    private var TimerEmojiProgress: some View {
        Text(postVM.totalSeconds < 5.0 ? "😃" : "🥳")
            .mask{
                Circle()
                    .frame(width: 22, height: 22)
            }
            .frame(width: 26, height: 26, alignment: .center)
            .overlay {
                ProgressView(value: postVM.secondsElapsed, total: postVM.maxDuration)
                    .progressViewStyle(TimerProgressViewStyle(width: 24))
                    .frame(width: 24, height: 24, alignment: .center)
            }
    }
    
    @ViewBuilder
    private var TimerTimeLabel: some View {
        Text(String(format: "%0.1fs", postVM.totalSeconds))
            .font(.system(size: 16, weight: .medium, design: .default))
            .foregroundColor(.primary)
            .colorInvert()
    }
    
    @ViewBuilder
    private var TimerControlButton: some View {
        Button {
            if postVM.stop {
                postVM.stop = false
                postVM.startTimer()
            } else {
                postVM.stop = true
                postVM.pauseTimer()
            }
        } label: {
            Image(systemName: postVM.stop ? "pause.fill" : "play.fill")
                .font(.system(size: 22, weight: .medium, design: .default))
                .foregroundColor(.primary)
                .colorInvert()
        }
    }
    
    private struct TimerProgressViewStyle: ProgressViewStyle {
        
        let size: CGSize
        
        init(size: CGSize) {
            self.size = size
        }
        
        init(width: CGFloat) {
            self.size = CGSize(width, width)
        }
        
        func makeBody(configuration: Configuration) -> some View {
            ZStack {
                Circle()
                    .stroke(style: StrokeStyle(lineWidth: 2.0, lineCap: .round, lineJoin: .round))
                    .foregroundColor(.secondary)
                    .frame(size)
                Circle()
                    .trim(from: 0.0, to: CGFloat(configuration.fractionCompleted ?? 0))
                    .stroke(style: StrokeStyle(lineWidth: 2.0, lineCap: .round, lineJoin: .round))
                    .foregroundColor(.primary)
                    .colorInvert()
                    .rotationEffect(.degrees(-90))
                    .frame(size)
            }
            
        }
    }
    
}
