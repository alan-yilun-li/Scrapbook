//
//  ScrapbookTests.swift
//  ScrapbookTests
//
//  Created by Alan Li on 2016-11-19.
//  Copyright © 2016 Alan Li. All rights reserved.
//

import XCTest
@testable import Scrapbook

class ScrapbookTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    // MARK: Scrapbook Tests
    
    // Tests to confirm that the Moment initializer returns when no name or caption is passed
    func testMomentInitialization() {
        
        // Success case
        let potentialItem = Moment(name: "First time at Pho!", photo: nil, caption: "whoah! it was pretty good")
        XCTAssertNotNil(potentialItem)
        
        
        // Failure case
        let noName = Moment(name: "", photo: nil, caption: "uh oh")
        XCTAssertNil(noName, "Empty name is invalid")
        
    }
    
    // Testing the pageViewController 
}
