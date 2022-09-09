//
//  SMSOTPAttempt.swift
//  vnvce
//
//  Created by Kerem Cesme on 19.08.2022.
//

import Foundation

struct SMSOTPAttempt: Codable {
    let attemptID: UUID
    let startTime: TimeInterval
    let expiryTime: TimeInterval
}
