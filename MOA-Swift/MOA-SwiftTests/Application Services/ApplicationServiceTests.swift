//
//  ApplicationServiceTests.swift
//  DynamicDataDrivenAppTests
//
//  Created by Mladen Despotovic on 20.11.18.
//  Copyright © 2018 Mladen Despotovic. All rights reserved.
//

import XCTest
@testable import MOA_Swift

class ApplicationServiceTests: XCTestCase {

    var mockPayUseCase: MockPayUseCase!
    
    override func setUp() {
        
        super.setUp()
        mockPayUseCase = MockPayUseCase(jsonFilename: "MockPayUseCase")
    }
    
    override func tearDown() {
        
        mockPayUseCase = nil
        super.tearDown()
    }
    
    // MARK: Testing assignValuesToServiceParameters from one particular array of dictionaries
    func test_assignValuesToServiceParameters_noValidParameters() {
        
        // Prepare
        let array = [
            ["%%not-a-response.paymentToken,%%not-a-response.somethingElse":
                ["paymentToken": "%%response.paymentToken"]
            ],
            ["%%not-a-response.somethingTotallyDifferent":
                ["paymentToken": "%%response.paymentToken"]
            ],
            ["not-a-response.somethingElse":
                ["paymentToken": "%%response.paymentToken"]
            ]
        ]
        mockPayUseCase.serviceParameters = ["##paymentToken": "abcd", "##amount": 100]
        let response: [String: Any]  = ["paymentToken": "1234", "amount": 200]
        
        // Execute
        mockPayUseCase.assignValuesToServiceParameters(from: array, response: response)
        
        // Test
        XCTAssertEqual(mockPayUseCase.serviceParameters["##paymentToken"] as! String, "abcd")
        XCTAssertEqual(mockPayUseCase.serviceParameters["##amount"] as! Int, 100)
    }
    
    func test_assignValuesToServiceParameters_singleValidParameter() {
        
        // Prepare
        let array = [
            ["%%response.paymentToken,%%not-a-response.amount":
                ["##paymentToken": "%%response.paymentToken"]
            ],
            ["%%not-a-response.somethingTotallyDifferent":
                ["##paymentToken": "%%response.paymentToken"]
            ],
            ["not-a-response.somethingElse":
                ["##paymentToken": "%%response.paymentToken"]
            ]
        ]
        mockPayUseCase.serviceParameters = ["##paymentToken": "abcd", "##amount": 100]
        let response: [String: Any]  = ["paymentToken": "1234", "amount": 200]
        
        // Execute
        mockPayUseCase.assignValuesToServiceParameters(from: array, response: response)
        
        // Test
        XCTAssertEqual(mockPayUseCase.serviceParameters["##paymentToken"] as! String, "1234")
        XCTAssertEqual(mockPayUseCase.serviceParameters["##amount"] as! Int, 100)
    }
    
    func test_assignValuesToServiceParameters_doubleValidParameter() {
        
        // Prepare
        let array = [
            ["%%response.paymentToken,%%response.amount":
                ["##paymentToken": "%%response.paymentToken",
                "##amount": "%%response.amount"]
            ],
            ["%%not-a-response.somethingTotallyDifferent":
                ["paymentToken": "%%response.paymentToken"]
            ],
            ["not-a-response.somethingElse":
                ["paymentToken": "%%response.paymentToken"]
            ]
        ]
        mockPayUseCase.serviceParameters = ["##paymentToken": "abcd", "##amount": 100]
        let response: [String: Any]  = ["paymentToken": "1234", "amount": 200]
        
        // Execute
        mockPayUseCase.assignValuesToServiceParameters(from: array, response: response)
        
        // Test
        XCTAssertEqual(mockPayUseCase.serviceParameters["##paymentToken"] as! String, "1234")
        XCTAssertEqual(mockPayUseCase.serviceParameters["##amount"] as! Int, 200)
    }
    
    func test_assignValuesToServiceParameters_twoValidParameters() {
        
        // Prepare
        let array = [
            ["%%response.paymentToken,%%not-a-valid.amount":
                ["##paymentToken": "%%response.paymentToken"]
            ],
            ["%%response.amount":
                ["##amount": "%%response.amount"]
            ],
            ["not-a-response.somethingElse":
                ["paymentToken": "%%response.paymentToken"]
            ]
        ]
        mockPayUseCase.serviceParameters = ["##paymentToken": "abcd", "##amount": 100]
        let response: [String: Any]  = ["paymentToken": "1234", "amount": 200]
        
        // Execute
        mockPayUseCase.assignValuesToServiceParameters(from: array, response: response)
        
        // Test
        XCTAssertEqual(mockPayUseCase.serviceParameters["##paymentToken"] as! String, "1234")
        XCTAssertEqual(mockPayUseCase.serviceParameters["##amount"] as! Int, 200)
    }
    
    // MARK: Running the service
    
    func test_run() {

		let router = ApplicationRouter()
		router.instantiatedModules = [MockLoginModule(),
									  MockPaymentsModule()]
		mockPayUseCase.appRouter = router
        mockPayUseCase.run()
		
    }
}

class MockPayUseCase: ApplicationServiceType {

    var serviceParameters = [String : Any]()
    var service = [String : Any]()
    var appRouter: ApplicationRouterType = ApplicationRouter()
    var scheme = "testScheme"
	var bundle: Bundle

	required init?(jsonFilename: String?, bundle: Bundle = Bundle(for: MockPayUseCase.self)) {
		
		self.bundle = bundle
		if let serviceDictionary = self.bundle.loadJson(filename: jsonFilename!) {
            self.service = serviceDictionary
        }
    }
    
    func valid() -> Bool {
        return true
    }
    
    
}

class MockLoginModule: ModuleType {

	func setup(parameters: ModuleParameters?) {}
	
	var route: String = {
		return "login"
	}()
	
	var paths: [String] = {
		return ["/payment-token"]
	}()
	
	var subscribedRoutables: [ModuleRoutable.Type] = [MockRoutable.self]
	var instantiatedRoutables: [WeakContainer<ModuleRoutable>] = []
}

class MockPaymentsModule: ModuleType {
	
	func setup(parameters: ModuleParameters?) {}
	
	var route: String = {
		return "payments"
	}()
	
	var paths: [String] = {
		return ["/pay"]
	}()
	
	var subscribedRoutables: [ModuleRoutable.Type] = [MockRoutable.self]
	var instantiatedRoutables: [WeakContainer<ModuleRoutable>] = []
    var retainedRoutables: [ModuleRoutable] = []
}


class MockRoutable: ModuleRoutable {

	var spyRoute = false
    var spyInjectedObject = false
    var spyUrlParameterPassed = false
	
	required init() {}
	
	static func getPaths() -> [String] {
		return ["/payment-token",
				"/login"]
	}
	
	static func routable() -> ModuleRoutable {
		return self.init()
	}
	
	func route(parameters: ModuleParameters?, path: String?, injectedObjects: [String : Any]?, callback: ModuleCallback?) {
		spyRoute = true
        if injectedObjects != nil { spyInjectedObject = true }
        if let _ = parameters?["url"] {
            spyUrlParameterPassed = true
        }
		callback!(nil,nil,nil)
	}
}
