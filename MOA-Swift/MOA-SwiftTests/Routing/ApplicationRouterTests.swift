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
		
		// Prepare
		let url = URL(scheme: "testScheme",
					  host: "login",
					  path: "/payment-token",
					  parameters: ["parameterKey": "parameterValue"])
		let router = ApplicationRouter()
		router.instantiatedModules = [MockLoginModule()]
		
		// Execute and Test
		let expectationOpen = expectation(description: "expectationOpen")
		router.open(url: url!) { (response, urlResponse, responseError) in
			
			let routable = router.instantiatedModules.first?.instantiatedRoutables.first as! MockRoutable
			XCTAssertTrue(routable.spyRoute)
			expectationOpen.fulfill()
		}
		waitForExpectations(timeout: 2, handler: nil)
	}
    
    func test_openWithInjectedObject() {
        
        // Prepare
        let url = URL(scheme: "testScheme",
                      host: "login",
                      path: "/payment-token",
                      parameters: ["parameterKey": "parameterValue"])
        let router = ApplicationRouter()
        router.instantiatedModules = [MockLoginModule()]
        
        // Execute and Test
        let expectationOpen = expectation(description: "expectationOpen")
        router.open(url: url!, injectedObjects: ["inject": "me"]) { (response, urlResponse, responseError) in
            
            let routable = router.instantiatedModules.first?.instantiatedRoutables.first as! MockRoutable
            XCTAssertTrue(routable.spyInjectedObject)
            expectationOpen.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func test_openWithAddedUrlParameter() {
        
        // Prepare
        let url = URL(scheme: "testScheme",
                      host: "login",
                      path: "/payment-token",
                      parameters: ["parameterKey": "parameterValue"])
        let router = ApplicationRouter()
        router.instantiatedModules = [MockLoginModule()]
        
        // Execute and Test
        let expectationOpen = expectation(description: "expectationOpen")
        router.open(url: url!) { (response, urlResponse, responseError) in
            
            let routable = router.instantiatedModules.first?.instantiatedRoutables.first as! MockRoutable
            XCTAssertTrue(routable.spyUrlParameterPassed)
            expectationOpen.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
    }
}

//class MockTestModule: ModuleType {
//
//	func setup(parameters: ModuleParameters?) {}
//	
//	var route: String = {
//		return "test-module"
//	}()
//
//	var paths: [String] = {
//		return ["/test-method"]
//	}()
//
//	var subscribedRoutables: [ModuleRoutable.Type] = [MockTestRoutable.self]
//	var instantiatedRoutables: [WeakContainer<ModuleRoutable>] = []
//}
//
//class MockTestRoutable: ModuleRoutable {
//
//	var spyRoute = false
//
//	required init() {}
//
//	static func getPaths() -> [String] {
//		return ["/test-method"]
//	}
//
//	static func routable() -> ModuleRoutable {
//		return self.init()
//	}
//
//	func route(parameters: ModuleParameters?, path: String?, callback: ModuleCallback?) {
//		spyRoute = true
//	}
//}

