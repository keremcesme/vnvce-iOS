//
//  SendSMSOTPPayload.swift
//  vnvce
//
//  Created by Kerem Cesme on 19.08.2022.
//

import Foundation

struct SendSMSOTPPayload: Encodable {
    let phoneNumber: String
    let clientID: UUID
    let type: SMSType
}
