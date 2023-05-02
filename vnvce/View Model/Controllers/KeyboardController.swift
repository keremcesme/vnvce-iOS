//
//  KeyboardController.swift
//  vnvce
//
//  Created by Kerem Cesme on 9.09.2022.
//

import Foundation
import SwiftUI
import Combine

class KeyboardController: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0
    @Published var height: CGFloat = 0
    @Published var duration: CGFloat = 0
    @Published var isShowed: Bool = false
    
    init() {
        self.listenForKeyboardNotifications()
    }
    
    private func listenForKeyboardNotifications() {
        DispatchQueue.main.async {
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification,
                                                   object: nil,
                                                   queue: .main) { (notification) in
                guard
                    let userInfo = notification.userInfo,
                    let keyboardRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
                    let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? CGFloat
                else { return }
                DispatchQueue.main.async {
                    self.duration = duration
                    self.height = keyboardRect.height
                    self.isShowed = true
                    withAnimation(.spring(response: duration, dampingFraction: 1, blendDuration: 0)){
                        self.keyboardHeight = keyboardRect.height
                    }
                }
                
            }
            
            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillHideNotification,
                object: nil,
                queue: .main
            ) { (notification) in
                guard
                    let userInfo = notification.userInfo,
                    let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? CGFloat
                else { return }
                
                DispatchQueue.main.async {
                    self.duration = duration
                    self.isShowed = false
                    withAnimation(.spring(response: duration, dampingFraction: 1, blendDuration: 0)){
                        self.keyboardHeight = 0
                    }
                }
                
            }
            
        }
        
        
        
        
    }
}

