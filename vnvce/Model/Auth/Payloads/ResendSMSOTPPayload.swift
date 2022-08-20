//
//  ResendSMSOTPPayload.swift
//  vnvce
//
//  Created by Kerem Cesme on 20.08.2022.
//

import Foundation

struct ResendSMSOTPPayload: Encodable {
    let phoneNumber: String
    let clientID: UUID
    let type: SMSType
}
