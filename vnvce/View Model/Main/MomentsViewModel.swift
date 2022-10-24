//
//  MomentsViewModel.swift
//  vnvce
//
//  Created by Kerem Cesme on 24.10.2022.
//

import Foundation
import SwiftUI
import Nuke
import ScrollViewPrefetcher

class MomentsViewModel: ObservableObject {
    private let momentAPI = MomentAPI.shared
    
    @Published public var moments: [MomentDay] = []
    
    func fetchMoments() async {
        if Task.isCancelled { return }
        do {
            let result = try await momentAPI.fetchMoments(.me)
            if Task.isCancelled { return }
            await MainActor.run {
                self.moments = result
                print("MOEMNTS: \(moments)")
            }
        } catch {
            print(error.localizedDescription)
            return
        }
    }
}
