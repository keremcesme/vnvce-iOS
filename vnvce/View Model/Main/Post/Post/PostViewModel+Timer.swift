//
//  PostViewModel+Timer.swift
//  vnvce
//
//  Created by Kerem Cesme on 24.09.2022.
//

import SwiftUI

extension PostViewModel {
    
    public func startTimer() {
        timerIsRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            self.secondsElapsed += 0.01
            self.totalSeconds += 0.01
            
            if self.secondsElapsed >= self.maxDuration && self.totalSeconds < 27 {
                self.maxDuration = 4.0
                self.secondsElapsed = 0
//                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
//            if self.secondsElapsed <= self.maxDuration  {
//                self.secondsElapsed += 0.01
//                self.totalSeconds += 0.01
//            } else {
//                self.maxDuration = 4.0
//                self.secondsElapsed = 0
//            }
        }
        if timer != nil {
            RunLoop.current.add(timer!, forMode: .common)
        }
    }
    
    public func stopTimer() {
        timer?.invalidate()
        secondsElapsed = 0
        timerIsRunning = false
    }
    
    public func pauseTimer() {
        timer?.invalidate()
        timerIsRunning = false
    }
    
}
