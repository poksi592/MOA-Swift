//
//  ApplicationRouterTests.swift
//  MOA-SwiftTests
//
//  Created by Mladen Despotovic on 31.03.19.
//  Copyright © 2019 Mladen Despotovic. All rights reserved.
//

import XCTest
@testable import MOA_Swift

class ApplicationRouterTests: XCTestCase {

	func test_openWithPath() {
        let router = ApplicationRouter<DependenciesProviderMock>(Module(route: "login", routable: MockRoutable.self))
        let url = URL(
            scheme: "testScheme",
            host: "login",
            path: "/payment-token",
            parameters: ["parameterKey": "parameterValue"]
        )!

		let expectationOpen = expectation(description: "expectationOpen")
        var routable: MockRoutable!
        router.open(url: url, dependenciesProvider: DependenciesProviderMock()) { (response, urlResponse, responseError) in
            routable = router.modules.first?.instantiatedRoutable as? MockRoutable
			expectationOpen.fulfill()
		}
		waitForExpectations(timeout: 1, handler: nil)

        XCTAssertTrue(routable.spyRoute)
	}

    func test_openWithAddedUrlParameter() {
        let router = ApplicationRouter<DependenciesProviderMock>(Module(route: "login", routable: MockRoutable.self))
        let url = URL(
            scheme: "testScheme",
            host: "login",
            path: "/payment-token",
            parameters: ["parameterKey": "parameterValue"]
        )!

        let expectationOpen = expectation(description: "expectationOpen")
        var routable: MockRoutable!
        router.open(url: url, dependenciesProvider: DependenciesProviderMock()) { (response, urlResponse, responseError) in
            routable = router.modules.first?.instantiatedRoutable as? MockRoutable
            expectationOpen.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)

        XCTAssertTrue(routable.spyUrlParameterPassed)
    }
}

private final class DependenciesProviderMock: DependenciesProvider {
    let intentsStorage = IntentsStorage()
}

private final class MockRoutable: Routable<DependenciesProviderMock> {
    var spyRoute = false
    var spyUrlParameterPassed = false

    override class var paths: [String] {
        [
            "/payment-token",
            "/login"
        ]
    }

    override func route(parameters: ModuleParameters, dependenciesProvider: DependenciesProviderMock, path: String?, callback: @escaping ModuleCallback) {
        spyRoute = true
        if let _ = parameters["url"] {
            spyUrlParameterPassed = true
        }
        callback(nil,nil,nil)
    }
}
