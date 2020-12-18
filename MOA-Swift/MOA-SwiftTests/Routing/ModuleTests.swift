//
//  ModuleTests.swift
//  MOA-SwiftTests
//
//  Created by Mladen Despotovic on 31.03.19.
//  Copyright © 2019 Mladen Despotovic. All rights reserved.
//

import XCTest
@testable import MOA_Swift

class ModuleTests: XCTestCase {

	func test_openWithoutParameters() {
        let loginModule = Module(route: "login", routable: MockRoutable.self)
		let expectationOpen = expectation(description: "expectationOpen")
        var routable: MockRoutable!
        loginModule.open(parameters: [:], dependenciesProvider: DependenciesProviderMock(), path: "/payment-token") { (response, urlResponse, error) in
            routable = loginModule.instantiatedRoutable as? MockRoutable
            expectationOpen.fulfill()
		}
		waitForExpectations(timeout: 2, handler: nil)

        XCTAssertNotNil(routable)
        XCTAssertTrue(routable.spyRoute)
	}

	func test_openWithParameters_Routable() {
        let loginModule = Module(route: "login", routable: MockRoutable.self)

		let expectationOpen = expectation(description: "expectationOpen")
        var routable: MockRoutable!
        loginModule.open(parameters: [:], dependenciesProvider: DependenciesProviderMock(), path: "/payment-token") { (response, urlResponse, error) in
            routable = loginModule.instantiatedRoutable as? MockRoutable
			expectationOpen.fulfill()
		}
		waitForExpectations(timeout: 2, handler: nil)

        XCTAssertNotNil(routable)
	}

    func test_open_dispatchingToInstanciatedModule() {
        let loginModule = Module(route: "login", routable: MockRoutable.self)
        let expectationOpen1 = expectation(description: "expectationOpen")
        var routable1: MockRoutable!
        loginModule.open(parameters: [:], dependenciesProvider: DependenciesProviderMock(), path: "/payment-token") { (response, urlResponse, error) in
            routable1 = loginModule.instantiatedRoutable as? MockRoutable
            expectationOpen1.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)

        let expectationOpen2 = expectation(description: "expectationOpen")
        var routable2: MockRoutable!
        loginModule.open(parameters: [:], dependenciesProvider: DependenciesProviderMock(), path: "/payment-token") { (response, urlResponse, error) in
            routable2 = loginModule.instantiatedRoutable as? MockRoutable
            expectationOpen2.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)

        XCTAssertEqual(routable1, routable2)
    }
}

private final class MockRoutable: Routable<DependenciesProviderMock>, Equatable {
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

    static func == (lhs: MockRoutable, rhs: MockRoutable) -> Bool { lhs === rhs }
}

private final class DependenciesProviderMock: DependenciesProvider {
    let intentsStorage = IntentsStorage()
}
