//
//  URLExtensionsTests.swift
//  MOA-SwiftTests
//
//  Created by Mladen Despotovic on 29.03.19.
//  Copyright © 2019 Mladen Despotovic. All rights reserved.
//

import XCTest
@testable import MOA_Swift

class URLExtensionsTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
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
	
	func test_initValidScheme() {
		
		let url = URL(schema: "myscheme",
					  host: "myhost")
		XCTAssertNotNil(url)
	}
	
//	func test_initIncorrectParameters() {
//
//		let url = URL(schema: "234623", host: "234345")
//		XCTAssertNil(url)
//	}
	
	func test_initAllParameters() {
		
		let url = URL(schema: "myscheme",
					  host: "myhost",
					  path: "/mypath",
					  parameters: ["parameterKey": "parameterValue"])
		XCTAssertNotNil(url)
		XCTAssertEqual(url?.scheme, "myscheme")
		XCTAssertEqual(url?.host, "myhost")
		XCTAssertEqual(url?.path, "/mypath")
	}

	func test_isValidSchemeValid() {
		
		let scheme = "a1sd+c.d-w"
		XCTAssertTrue(scheme.isValidScheme)
	}
	
	func test_isValidSchemeNotFirstLetter() {
		
		let scheme = "1sd+c.d-w"
		XCTAssertFalse(scheme.isValidScheme)
	}
	
	func test_isValidSchemeFirstWhitespace() {
		
		let scheme = " a1sd+c.d-w"
		XCTAssertFalse(scheme.isValidScheme)
	}
	
	func test_isValidSchemeWhitespace() {
		
		let scheme = "a1sd+c.d-w "
		XCTAssertFalse(scheme.isValidScheme)
	}
	
	func test_isValidSchemeInvalidCharacter1() {
		
		let scheme = "a1sd+c.d-w("
		XCTAssertFalse(scheme.isValidScheme)
	}
	
	func test_isValidSchemeInvalidCharacter2() {
		
		let scheme = "a1sd+c.d-w*"
		XCTAssertFalse(scheme.isValidScheme)
	}
}
