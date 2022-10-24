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
    public var TimerBar: some View {
        HStack(spacing: 8){
            TimerEmojiProgress
            TimerTimeLabel
//            Spacer()
//            TimerControlButton
        }
//        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .padding(.trailing, 4)
        .background(Color.primary)
        .clipShape(Capsule())
//        .padding(.horizontal, 100)
        .padding(.bottom, UIDevice.current.postTimerBarBottomPadding)
        .opacity(postsVM.selectedPost.show ? 1 : 0.00001)
        .taskInit {
            
        }
//        .onChange(of: postsVM.selectedPost.ready) {
//            if $0 {
//                postVM.startTimer()
//            }
//        }
//        .onChange(of: postVM.secondsElapsed) { value in
////            print(String(format: "%0.1fs", postVM.secondsElapsed))
//            DispatchQueue.main.async {
//                if value >= postVM.maxDuration {
//                    self.postVM.maxDuration = 4.0
//                    self.postVM.secondsElapsed = 0.0
//                }
//            }
//        }
    }
    
    @ViewBuilder
    private var TimerEmojiProgress: some View {
//        Group {
//            Text(postVM.totalSeconds < 5.0 ? "😃" : "🥳")
            Image(uiImage: timerImage())
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 19, height: 19)
                .scaleEffect(emojiScale)
            .mask{
                Circle()
                    .frame(width: 22, height: 22)
            }
            .frame(width: 26, height: 26, alignment: .center)
            .overlay {
                if postVM.totalSeconds < 27 {
                    ProgressView(value: postVM.secondsElapsed, total: postVM.maxDuration)
                        .progressViewStyle(TimerProgressViewStyle(width: 24))
                        .frame(width: 24, height: 24, alignment: .center)
                }
            }
    }
    
    //            Text(String(format: "%0.1fs", postVM.totalSeconds))
    @ViewBuilder
    private var TimerTimeLabel: some View {
        HStack {
            HStack(spacing:0) {
                let seconds = Int(postVM.totalSeconds)
                
                ForEach(seconds.digits, id: \.self) { number in
                    Text("\(number)")
                        .frame(width: 9.6, alignment: .center)
                }
                Text(".")
                Text("\(Int((postVM.totalSeconds - Double(Int(postVM.totalSeconds))) * 10))")
                    .frame(width: 9.6)
                Text("s")
            }
        }
        .foregroundColor(.primary)
        .font(.system(size: 16, weight: .medium, design: .default))
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
    
    private func timerImage() -> UIImage {
        switch postVM.totalSeconds {
//        case (0...3):
//            return UIImage()
        case (0..<7):
            return LikeEmojiLevel.level1.image
        case (7..<11):
            return LikeEmojiLevel.level2.image
        case (11..<15):
            return LikeEmojiLevel.level3.image
        case (15..<19):
            return LikeEmojiLevel.level4.image
        case (19..<23):
            return LikeEmojiLevel.level5.image
        case (23..<27):
            return LikeEmojiLevel.level6.image
        default:
            return LikeEmojiLevel.level7.image
        }
    }
    
    private var emojiScale: CGFloat {
        if postVM.totalSeconds < 3 {
            return postVM.totalSeconds / 3
        } else {
            return 1
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
