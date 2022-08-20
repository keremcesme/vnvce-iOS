//
//  CheckPhoneNumberResponse.swift
//  vnvce
//
//  Created by Kerem Cesme on 18.08.2022.
//

import Foundation

struct CheckPhoneNumberResponse: Decodable {
    let status: PhoneNumberAvailability
}
