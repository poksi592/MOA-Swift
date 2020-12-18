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
	func test_initValidScheme() {
		let url = URL(scheme: "myscheme", host: "myhost")

		XCTAssertNotNil(url)
	}
	
	func test_initIncorrectParameters() {
		let url = URL(scheme: "234623", host: "234345")

		XCTAssertNil(url)
	}
	
	func test_initAllParameters() {
		let url = URL(
            scheme: "myscheme",
            host: "myhost",
            path: "/mypath",
            parameters: ["parameterKey": "parameterValue"]
        )

		XCTAssertNotNil(url)
		XCTAssertEqual(url?.scheme, "myscheme")
		XCTAssertEqual(url?.host, "myhost")
		XCTAssertEqual(url?.path, "/mypath")
	}
    func testURLComponents_QueryItemsDictionary() {
        let components = URLComponents(string: "http://test.test?parameter1=123&parameter2=321")!

        let dictionary = components.queryItemsDictionary

        XCTAssertEqual(dictionary, ["parameter1": "123", "parameter2": "321"])
    }

    func test_isValidValid() {
        XCTAssertTrue("a1sd+c.d-w".isValidSchemeName)
    }

    func test_isValidNotFirstLetter() {
        XCTAssertFalse("1sd+c.d-w".isValidSchemeName)
    }

    func test_isValidFirstWhitespace() {
        XCTAssertFalse(" a1sd+c.d-w".isValidSchemeName)
    }

    func test_isValidWhitespace() {
        XCTAssertFalse("a1sd+c.d-w ".isValidSchemeName)
    }

    func test_isValidInvalidCharacter1() {
        XCTAssertFalse("a1sd+c.d-w(".isValidSchemeName)
    }

    func test_isValidInvalidCharacter2() {
        XCTAssertFalse("a1sd+c.d-w*".isValidSchemeName)
    }

    func test_isValidLettersOnly() {
        XCTAssertTrue("abcd".isValidHostName)
    }

    func test_isValidLettersAndDash() {
        XCTAssertTrue("abc-d".isValidHostName)
    }

    func test_isValidLettersAndNumbers() {
        XCTAssertTrue("abc-d9".isValidHostName)
    }

    func test_isValidHostNameNotFirstLetter() {
        XCTAssertFalse("9abc-d9".isValidHostName)
    }

    func test_isValidHostNameInvalidCharacter1() {
        XCTAssertFalse("abc-d9*".isValidHostName)
    }

    func test_isValidHostNameInvalidCharacter2() {
        XCTAssertFalse("abc-d9.".isValidHostName)
    }

    func test_isValidPathModuleLettersOnly() {
        XCTAssertTrue("/abcd".isValidPathModule)
    }

    func test_isValidPathModuleLettersAndDash() {
        XCTAssertTrue("/abc-d".isValidPathModule)
    }

    func test_isValidPathModuleLettersAndNumbers() {
        XCTAssertTrue("/abc-d9".isValidPathModule)
    }

    func test_isValidPathModuleNotSlach() {
        XCTAssertFalse("abc-d9".isValidPathModule)
    }

    func test_isValidPathModuleInvalidCharacter1() {
        XCTAssertFalse("/abc-d9*".isValidPathModule)
    }

    func test_isValidPathModuleInvalidCharacter2() {
        XCTAssertFalse("/abc-d9.".isValidPathModule)
    }
}
