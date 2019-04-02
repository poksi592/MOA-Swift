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
		
		let url = URL(schema: "myscheme",
					  host: "myhost")
		XCTAssertNotNil(url)
	}
	
	func test_initIncorrectParameters() {

		let url = URL(schema: "234623", host: "234345")
		XCTAssertNil(url)
	}
	
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
	
	// MARK: Test scheme

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
	
	// MARK: Test Host
	
	func test_isValidHostModuleLettersOnly() {
		
		let moduleName = "abcd"
		XCTAssertTrue(moduleName.isValidHostModule)
	}
	
	func test_isValidHostModuleLettersAndDash() {
		
		let moduleName = "abc-d"
		XCTAssertTrue(moduleName.isValidHostModule)
	}
	
	func test_isValidHostModuleLettersAndNumbers() {
		
		let moduleName = "abc-d9"
		XCTAssertTrue(moduleName.isValidHostModule)
	}
	
	func test_isValidHostModuleNotFirstLetter() {
		
		let moduleName = "9abc-d9"
		XCTAssertFalse(moduleName.isValidHostModule)
	}
	
	func test_isValidHostModuleInvalidCharacter1() {
		
		let moduleName = "abc-d9*"
		XCTAssertFalse(moduleName.isValidHostModule)
	}
	
	func test_isValidHostModuleInvalidCharacter2() {
		
		let moduleName = "abc-d9."
		XCTAssertFalse(moduleName.isValidHostModule)
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
		let url = URL(schema: "testScheme",
					  host: "myhost")
		let bundle = Bundle(for: URLExtensionsTests.self)
		
		// Execute
		let hasScheme = url!.containsInAppSchema(for: bundle)
		
		// Testz
		XCTAssertNotNil(hasScheme)
	}
	
	func test_containsInAppSchemeInvalidScheme() {
		
		// Prepare
		let url = URL(schema: "myscheme",
					  host: "myhost")
		let bundle = Bundle(for: URLExtensionsTests.self)
		
		// Execute
		let hasScheme = url!.containsInAppSchema(for: bundle)
		
		// Test
		XCTAssertNotNil(hasScheme)
	}
	
	func test_isHttpAddressHttp() {
		
		// Prepare
		let url = URL(schema: "http",
					  host: "myhost")
		// Test
		XCTAssertTrue(url!.isHttpAddress)
	}
	
	func test_isHttpAddressHttps() {
		
		// Prepare
		let url = URL(schema: "https",
					  host: "myhost")
		// Test
		XCTAssertTrue(url!.isHttpAddress)
	}
	
	func test_isHttpAddressNot() {
		
		// Prepare
		let url = URL(schema: "myscheme",
					  host: "myhost")
		// Test
		XCTAssertFalse(url!.isHttpAddress)
	}
}

