//
//  vnvceUITests.swift
//  vnvceUITests
//
//  Created by Kerem Cesme on 10.08.2022.
//

import XCTest

class vnvceUITests: XCTestCase {

    func testClickCreateAccountButton() throws {
        let app = XCUIApplication()
        app.launch()
        
        app.buttons["Don't have an account?, Create account"].tap()
        
    }
    
    func testCreateAccount() throws {
        let app = XCUIApplication()
        app.launch()
                
    }
    
}
