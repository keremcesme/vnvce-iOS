//
//  UsernameRegex.swift
//  vnvce
//
//  Created by Kerem Cesme on 12.08.2022.
//

import Foundation

func usernameRegex(username: String) async -> Bool{
    let usernameRegex = "^(?=.{3,20}$)(?=.*?[a-zA-Z]{2})(?![._])(?!.*[_.]{2})[a-zA-Z0-9._]+$"
    let inputpred = NSPredicate(format: "SELF MATCHES %@", usernameRegex)
    return inputpred.evaluate(with: username)
}

func usernameRegex(username: String) -> Bool {
    let usernameRegex = "^(?=.{3,20}$)(?=.*?[a-zA-Z]{2})(?![._])(?!.*[_.]{2})[a-zA-Z0-9._]+$"
    let inputpred = NSPredicate(format: "SELF MATCHES %@", usernameRegex)
    return inputpred.evaluate(with: username)
}
