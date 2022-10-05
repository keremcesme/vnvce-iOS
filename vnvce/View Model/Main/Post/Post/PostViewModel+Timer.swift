//
//  PostViewModel+Timer.swift
//  vnvce
//
//  Created by Kerem Cesme on 24.09.2022.
//

import SwiftUI

extension PostViewModel {
    
    public func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            if self.secondsElapsed < self.maxDuration - 0.1 {
                self.secondsElapsed += 0.05
                self.totalSeconds += 0.05
            }
        }
        if timer != nil {
            RunLoop.current.add(timer!, forMode: .common)
        }
    }
    
    public func stopTimer() {
        timer?.invalidate()
        secondsElapsed = 0
    }
    
    public func pauseTimer() {
        timer?.invalidate()
    }
    
}
