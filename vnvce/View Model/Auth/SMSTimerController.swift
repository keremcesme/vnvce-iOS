//
//  SMSTimerController.swift
//  vnvce
//
//  Created by Kerem Cesme on 18.08.2022.
//

import Foundation
import Combine

class SMSTimerController: ObservableObject {
    /// String to show in UI
    @Published private(set) var message = "Not running"
    @Published private(set) var remaining: Int = 60
    
    /// Is the timer running?
    @Published private(set) var isRunning = false
    
    /// Time that we're counting from
    private var startTime: Date? { didSet { saveStartTime() } }
    private var expireTime: Date? { didSet { saveExpireTime() } }
    
    /// The timer
    private var timer: AnyCancellable?
    
    func commonInit(start: TimeInterval, expire: TimeInterval) {
        let startDate = Date(timeIntervalSince1970: start)
        let expireDate = Date(timeIntervalSince1970: expire)
        
        UserDefaults.standard.removeObject(forKey: "smsStartTime")
        UserDefaults.standard.removeObject(forKey: "smsExpireTime")
        UserDefaults.standard.set(startDate, forKey: "smsStartTime")
        UserDefaults.standard.set(expireDate, forKey: "smsExpireTime")
        
        startTime = fetchStartTime()
        expireTime = fetchExpireTime()
        
        if startTime != nil {
            startTask()
        }
    }
}

extension SMSTimerController {
    func startTask() {
        timer?.cancel()
        if startTime == nil {
            startTime = Date()
        }
        if expireTime == nil {
            expireTime = Date().addingTimeInterval(60)
        }
        message = ""
        remaining = 60
        timer = Timer
            .publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard
                    let self = self,
                    let startTime = self.startTime,
                    let expireTime = self.expireTime
                else { return }
                _ =  Date().timeIntervalSince(startTime) // elapsed
                let total =  Date().timeIntervalSince(expireTime)
                let remaing = NSInteger(total)
                let seconds = remaing % 60
                if -seconds <= 0 {
                    self.stop()
                    return
                }
                self.message = String(-seconds)
                self.remaining = Int(-seconds)
            }
        
        isRunning = true
    }
    
    func stop() {
        timer?.cancel()
        timer = nil
        startTime = nil
        expireTime = nil
        isRunning = false
        message = "Not running"
        remaining = 0
    }
}

// MARK: - Private implementation
extension SMSTimerController {
    func saveStartTime() {
        if let startTime = startTime {
            UserDefaults.standard.set(startTime, forKey: "smsStartTime")
        } else {
            UserDefaults.standard.removeObject(forKey: "smsStartTime")
        }
    }
    
    func saveExpireTime() {
        if let expireTime = expireTime {
            UserDefaults.standard.set(expireTime, forKey: "smsExpireTime")
        } else {
            UserDefaults.standard.removeObject(forKey: "smsExpireTime")
        }
    }
    
    func fetchStartTime() -> Date? {
        UserDefaults.standard.object(forKey: "smsStartTime") as? Date
    }
    
    func fetchExpireTime() -> Date? {
        UserDefaults.standard.object(forKey: "smsExpireTime") as? Date
    }
}
