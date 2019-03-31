//
//  BundleTests.swift
//  MOA-SwiftTests
//
//  Created by Mladen Despotovic on 31.03.19.
//  Copyright © 2019 Mladen Despotovic. All rights reserved.
//

import XCTest
@testable import MOA_Swift

class BundleTests: XCTestCase {

	func test_urlSchemes() {
		
		let bundle = Bundle(for: BundleTests.self)
		XCTAssertNotNil(bundle.urlSchemes)
	}

}
