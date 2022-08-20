//
//  ResendSMSOTPResponse.swift
//  vnvce
//
//  Created by Kerem Cesme on 20.08.2022.
//

import Foundation

struct ResendSMSOTPResponse: Decodable {
    let status: SMSOTPAttempt
}
