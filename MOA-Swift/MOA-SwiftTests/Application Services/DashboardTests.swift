//
//  ApplicationServicesTests.swift
//  MOA-SwiftTests
//
//  Created by Mladen Despotovic on 31.03.19.
//  Copyright © 2019 Mladen Despotovic. All rights reserved.
//

import XCTest
@testable import MOA_Swift

class ApplicationServicesTests: XCTestCase {

	func test_init() {
		
		let dashboard = Dashboard()
		XCTAssertNotNil(dashboard.appRouter)
	}

}
