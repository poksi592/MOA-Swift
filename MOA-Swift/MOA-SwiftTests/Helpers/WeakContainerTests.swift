//
//  WeakContainerTests.swift
//  MOA-SwiftTests
//
//  Created by Mladen Despotovic on 29.03.19.
//  Copyright © 2019 Mladen Despotovic. All rights reserved.
//

import XCTest
@testable import MOA_Swift

class WeakContainerTests: XCTestCase {
	
	func test_init() {
		
		let stringContainer = WeakContainer<String>.init(value: "Test String")
		
		XCTAssertEqual(stringContainer.value, "Test String")
	}
}
