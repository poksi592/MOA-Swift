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

	func test_openWithParameters() {
		
		// Prepare
		let loginModule = MockLoginModule()
		
		// Execute and Test
		let expectationOpen = expectation(description: "expectationOpen")
		loginModule.open(parameters: nil, path: "/payment-token") { (response, urlResponse, error) in
			
			let routable = loginModule.instantiatedRoutables.first?.value as! MockRoutable
			XCTAssertTrue(routable.spyRoute)
			expectationOpen.fulfill()
		}
		waitForExpectations(timeout: 2, handler: nil)
	}
	
	func test_openWithParametersRoutables() {
		
		// Prepare
		let loginModule = MockLoginModule()
		
		// Execute and Test
		let expectationOpen = expectation(description: "expectationOpen")
		loginModule.open(parameters: nil, path: "/payment-token") { (response, urlResponse, error) in
			
			let routables = loginModule.instantiatedRoutables
			XCTAssertNotNil(routables)
			expectationOpen.fulfill()
		}
		waitForExpectations(timeout: 2, handler: nil)
	}
	
	func test_responseErrorInit401() {
		
		let error = NSError(domain: "mydomain", code: 401, userInfo: nil)
		let responseError = ResponseError(error: error, response: nil, code: 401)
		
		if case .unauthorized401(let payloadError) = responseError! {
			XCTAssertNotNil(payloadError)
			XCTAssertEqual(responseError?.errorCode, 401)
		}
		else {
			XCTAssertTrue(false, "error")
		}
	}
	
	func test_responseErrorInit400() {
		
		let error = NSError(domain: "mydomain", code: 400, userInfo: nil)
		let responseError = ResponseError(error: error, response: nil, code: 400)
		
		if case .badRequest400(let payloadError) = responseError! {
			XCTAssertNotNil(payloadError)
			XCTAssertEqual(responseError?.errorCode, 400)
		}
		else {
			XCTAssertTrue(false, "error")
		}
	}
	
	func test_responseErrorInit403() {
		
		let error = NSError(domain: "mydomain", code: 403, userInfo: nil)
		let responseError = ResponseError(error: error, response: nil, code: 403)
		
		if case .forbidden403(let payloadError) = responseError! {
			XCTAssertNotNil(payloadError)
			XCTAssertEqual(responseError?.errorCode, 403)
		}
		else {
			XCTAssertTrue(false, "error")
		}
	}
	
	func test_responseErrorInit404() {
		
		let error = NSError(domain: "mydomain", code: 404, userInfo: nil)
		let responseError = ResponseError(error: error, response: nil, code: 404)
		
		if case .notFound404(let payloadError) = responseError! {
			XCTAssertNotNil(payloadError)
			XCTAssertEqual(responseError?.errorCode, 404)
		}
		else {
			XCTAssertTrue(false, "error")
		}
	}
	
	func test_responseErrorInit405() {
		
		let error = NSError(domain: "mydomain", code: 405, userInfo: nil)
		let responseError = ResponseError(error: error, response: nil, code: 405)
		
		if case .other400(let payloadError) = responseError! {
			XCTAssertNotNil(payloadError)
			XCTAssertEqual(responseError?.errorCode, 405)
		}
		else {
			XCTAssertTrue(false, "error")
		}
	}
	
	func test_responseErrorInit200() {
		
		let error = NSError(domain: "mydomain", code: 200, userInfo: nil)
		let responseError = ResponseError(error: error, response: nil, code: 200)

		XCTAssertNil(responseError)
		XCTAssertNil(responseError?.errorCode)
	}
	
	func test_responseErrorInit500() {
		
		let error = NSError(domain: "mydomain", code: 500, userInfo: nil)
		let responseError = ResponseError(error: error, response: nil, code: 500)
		
		if case .serverError500(let payloadError) = responseError! {
			XCTAssertNotNil(payloadError)
			XCTAssertEqual(responseError?.errorCode, 500)
		}
		else {
			XCTAssertTrue(false, "error")
		}
	}
	
	func test_responseErrorNoInit() {
		
		let responseError = ResponseError(error: nil, response: nil, code: nil)
		
		if case .other = responseError! {
			XCTAssert(true)
		}
		else {
			XCTAssertTrue(false, "error")
		}
	}
	
	func test_responseErrorUrlresponse() {
		
		let urlResponse = HTTPURLResponse(url: URL(string: "www.apple.com")!,
										  statusCode: 400,
										  httpVersion: nil,
										  headerFields: nil)
		let responseError = ResponseError(error: nil, response: urlResponse, code: nil)
		
		if case .badRequest400(_) = responseError! {
			XCTAssert(true)
		}
		else {
			XCTAssertTrue(false, "error")
		}
	}
	
	func test_responseErrorErrorCode() {
		
		let error = NSError(domain: "mydomain", code: 401, userInfo: nil)
		let responseError = ResponseError(error: error, response: nil, code: 401)
		
		XCTAssertEqual(responseError?.errorCode!, 401)
	}
	
    func test_flushingEmptyInstantiatedRoutablesWeakContainer() {
        
        // Prepare
        let loginModule = MockLoginModule()
        
        // Execute First time and Test
        let expectationOpen1 = expectation(description: "expectationOpen")
        loginModule.open(parameters: nil, path: "/payment-token") { (response, urlResponse, error) in
            
            let routables = loginModule.instantiatedRoutables
            XCTAssertEqual(routables.count, 1)
            expectationOpen1.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
        
        // Execute Second time and Test
        let expectationOpen2 = expectation(description: "expectationOpen")
        loginModule.open(parameters: nil, path: "/payment-token") { (response, urlResponse, error) in
            
            let routables = loginModule.instantiatedRoutables
            XCTAssertEqual(routables.count, 1)
            expectationOpen2.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
        
        XCTAssertEqual(loginModule.instantiatedRoutables.count, 1)
        XCTAssertNil(loginModule.instantiatedRoutables.first?.value)
    }
	
}
