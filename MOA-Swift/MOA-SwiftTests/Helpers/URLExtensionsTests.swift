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
		
		let url = URL(scheme: "myscheme",
					  host: "myhost")
		XCTAssertNotNil(url)
	}
	
	func test_initIncorrectParameters() {

		let url = URL(scheme: "234623", host: "234345")
		XCTAssertNil(url)
	}
	
	func test_initAllParameters() {
		
		let url = URL(scheme: "myscheme",
					  host: "myhost",
					  path: "/mypath",
					  parameters: ["parameterKey": "parameterValue"])
		XCTAssertNotNil(url)
		XCTAssertEqual(url?.scheme, "myscheme")
		XCTAssertEqual(url?.host, "myhost")
		XCTAssertEqual(url?.path, "/mypath")
	}
	
	// MARK: Test scheme

	func test_isValidValid() {
		
		let scheme = "a1sd+c.d-w"
		XCTAssertTrue(scheme.isValidSchemeName)
	}
	
	func test_isValidNotFirstLetter() {
		
		let scheme = "1sd+c.d-w"
		XCTAssertFalse(scheme.isValidSchemeName)
	}
	
	func test_isValidFirstWhitespace() {
		
		let scheme = " a1sd+c.d-w"
		XCTAssertFalse(scheme.isValidSchemeName)
	}
	
	func test_isValidWhitespace() {
		
		let scheme = "a1sd+c.d-w "
		XCTAssertFalse(scheme.isValidSchemeName)
	}
	
	func test_isValidInvalidCharacter1() {
		
		let scheme = "a1sd+c.d-w("
		XCTAssertFalse(scheme.isValidSchemeName)
	}
	
	func test_isValidInvalidCharacter2() {
		
		let scheme = "a1sd+c.d-w*"
		XCTAssertFalse(scheme.isValidSchemeName)
	}
	
	// MARK: Test Host
	
	func test_isValidLettersOnly() {
		
		let moduleName = "abcd"
		XCTAssertTrue(moduleName.isValidHostName)
	}
	
	func test_isValidLettersAndDash() {
		
		let moduleName = "abc-d"
		XCTAssertTrue(moduleName.isValidHostName)
	}
	
	func test_isValidLettersAndNumbers() {
		
		let moduleName = "abc-d9"
		XCTAssertTrue(moduleName.isValidHostName)
	}
	
	func test_isValidHostNameNotFirstLetter() {
		
		let moduleName = "9abc-d9"
		XCTAssertFalse(moduleName.isValidHostName)
	}
	
	func test_isValidHostNameInvalidCharacter1() {
		
		let moduleName = "abc-d9*"
		XCTAssertFalse(moduleName.isValidHostName)
	}
	
	func test_isValidHostNameInvalidCharacter2() {
		
		let moduleName = "abc-d9."
		XCTAssertFalse(moduleName.isValidHostName)
	}
	
	// MARK: Test Path
	
	func test_isValidPathModuleLettersOnly() {
		
		let moduleName = "/abcd"
		XCTAssertTrue(moduleName.isValidPathModule)
	}
	
	func test_isValidPathModuleLettersAndDash() {
		
		let moduleName = "/abc-d"
		XCTAssertTrue(moduleName.isValidPathModule)
	}
	
	func test_isValidPathModuleLettersAndNumbers() {
		
		let moduleName = "/abc-d9"
		XCTAssertTrue(moduleName.isValidPathModule)
	}
	
	func test_isValidPathModuleNotSlach() {
		
		let moduleName = "abc-d9"
		XCTAssertFalse(moduleName.isValidPathModule)
	}
	
	func test_isValidPathModuleInvalidCharacter1() {
		
		let moduleName = "/abc-d9*"
		XCTAssertFalse(moduleName.isValidPathModule)
	}
	
	func test_isValidPathModuleInvalidCharacter2() {
		
		let moduleName = "/abc-d9."
		XCTAssertFalse(moduleName.isValidPathModule)
	}
	
	// MARK: Test Bundle
	
	func test_containsInAppSchemeValidScheme() {
		
		// Prepare
		let url = URL(scheme: "testScheme",
					  host: "myhost")
		let bundle = Bundle(for: URLExtensionsTests.self)
		
		// Execute
		let hasScheme = url!.containsInAppScheme(for: bundle)
		
		// Testz
		XCTAssertNotNil(hasScheme)
	}
	
	func test_containsInAppSchemeInvalidScheme() {
		
		// Prepare
		let url = URL(scheme: "myscheme",
					  host: "myhost")
		let bundle = Bundle(for: URLExtensionsTests.self)
		
		// Execute
		let hasScheme = url!.containsInAppScheme(for: bundle)
		
		// Test
		XCTAssertNotNil(hasScheme)
	}
	
	func test_isHttpAddressHttp() {
		
		// Prepare
		let url = URL(scheme: "http",
					  host: "myhost")
		// Test
		XCTAssertTrue(url!.isHttpAddress)
	}
	
	func test_isHttpAddressHttps() {
		
		// Prepare
		let url = URL(scheme: "https",
					  host: "myhost")
		// Test
		XCTAssertTrue(url!.isHttpAddress)
	}
	
	func test_isHttpAddressNot() {
		
		// Prepare
		let url = URL(scheme: "myscheme",
					  host: "myhost")
		// Test
		XCTAssertFalse(url!.isHttpAddress)
	}
}

