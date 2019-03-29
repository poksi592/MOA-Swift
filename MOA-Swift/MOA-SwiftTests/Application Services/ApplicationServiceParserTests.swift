//
//  ServiceParserTests.swift
//  DynamicDataDrivenAppTests
//
//  Created by Mladen Despotovic on 20.11.18.
//  Copyright © 2018 Mladen Despotovic. All rights reserved.
//

import XCTest
@testable import MOA_Swift

class ServiceParserTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    
    // MARK: Getting dictionary below one certain name of the service, which is being called recursively
    func test_getParametersDictionaryForService_validData() {
        
        // Prepare
        let array = [
                        ["@@pay":
                            ["##paymentToken": "%%response.paymentToken"]
                        ]
                    ]
        // Execute
        let result = ApplicationServiceParser.getParametersDictionaryForService(from: array, serviceName: "@@pay")
        
        //Test
        XCTAssert(result?.count == 1)
        XCTAssertEqual(result?["##paymentToken"] as! String, "%%response.paymentToken")
    }
    
    func test_getParametersDictionaryForService_noValidService() {
        
        // Prepare
        let array = [
            ["@@pay":
                ["##paymentToken": "%%response.paymentToken"]
            ]
        ]
        
        // Execute
        let result = ApplicationServiceParser.getParametersDictionaryForService(from: array, serviceName: "@@receive")
        
        //Test
        XCTAssertNil(result)
    }
    
    func test_getParametersDictionaryForService_noParameters() {
        
        // Prepare
        let array = [
            ["@@pay": nil]
        ]
        
        // Execute
        let result = ApplicationServiceParser.getParametersDictionaryForService(from: array, serviceName: "@@pay")
        
        //Test
        XCTAssertNil(result)
    }
    
    func test_getParametersDictionaryForService_emptyParameters() {
        
        // Prepare
        let array = [
            ["@@pay": [:]]
        ]
        
        // Execute
        let result = ApplicationServiceParser.getParametersDictionaryForService(from: array, serviceName: "@@pay")
        
        //Test
        XCTAssertNil(result)
    }
    
    func test_getParametersDictionaryForService_noValidParameters() {
        
        // Prepare
        let array = [
            ["@@pay":
                ["paymentToken": "%%response.paymentToken"]
            ]
        ]
        
        // Execute
        let result = ApplicationServiceParser.getParametersDictionaryForService(from: array, serviceName: "@@pay")
        
        //Test
        XCTAssertNil(result)
    }
    
    // MARK: Test updating current parameters' values with new ones from the dictionary passed
    func test_getResponseUpdatedServiceParameters_emptyParameters() {
        
        // Prepare
        let parameters = [String: Any]()
        let serviceParameters: [String: Any] = ["##paymentToken": "abcd", "##amount": 100]
        let response: [String: Any]  = ["paymentToken": "1234"]
        
        // Execute
        let result = ApplicationServiceParser.getResponseUpdatedServiceParameters(from: parameters,
                                                                                  serviceParameters: serviceParameters,
                                                                                  response: response)
        // Test
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result["##paymentToken"] as! String, "abcd")
        XCTAssertEqual(result["##amount"] as! Int, 100)
    }
    
    func test_getResponseUpdatedServiceParameters_noServiceParameters() {
        
        // Prepare
        let parameters = ["##paymentToken": "%%response.paymentToken"]
        let serviceParameters = [String: Any]()
        let response: [String: Any]  = ["paymentToken": "1234"]
        
        // Execute
        let result = ApplicationServiceParser.getResponseUpdatedServiceParameters(from: parameters,
                                                                                  serviceParameters: serviceParameters,
                                                                                  response: response)
        // Test
        XCTAssertEqual(result.count, 0)
    }
    
    func test_getResponseUpdatedServiceParameters_noResponseParameters() {
        
        // Prepare
        let parameters = ["##paymentToken": "%%response.paymentToken"]
        let serviceParameters: [String: Any] = ["##paymentToken": "abcd", "##amount": 100]
        let response = [String: Any]()
        
        // Execute
        let result = ApplicationServiceParser.getResponseUpdatedServiceParameters(from: parameters,
                                                                                  serviceParameters: serviceParameters,
                                                                                  response: response)
        // Test
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result["##paymentToken"] as! String, "abcd")
        XCTAssertEqual(result["##amount"] as! Int, 100)
    }
    
    func test_getResponseUpdatedServiceParameters_fullResponsePaymentTokenParameters() {
        
        // Prepare
        let parameters = ["##paymentToken": "%%response.paymentToken"]
        let serviceParameters: [String: Any] = ["##paymentToken": "abcd", "##amount": 100]
        let response: [String: Any]  = ["paymentToken": "1234", "amount": 100]
        
        // Execute
        let result = ApplicationServiceParser.getResponseUpdatedServiceParameters(from: parameters,
                                                                                  serviceParameters: serviceParameters,
                                                                                  response: response)
        // Test
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result["##paymentToken"] as! String, "1234")
        XCTAssertEqual(result["##amount"] as! Int, 100)
    }
    
    func test_getResponseUpdatedServiceParameters_fullResponseAmountParameters() {
        
        // Prepare
        let parameters = ["##amount": "%%response.amount"]
        let serviceParameters: [String: Any] = ["##paymentToken": "abcd", "##amount": 100]
        let response: [String: Any]  = ["paymentToken": "1234", "amount": 200]
        
        // Execute
        let result = ApplicationServiceParser.getResponseUpdatedServiceParameters(from: parameters,
                                                                                  serviceParameters: serviceParameters,
                                                                                  response: response)
        // Test
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result["##paymentToken"] as! String, "abcd")
        XCTAssertEqual(result["##amount"] as! Int, 200)
    }

    // MARK Testing functionality to extract from array only the dictionary statements, which match response parameters
    func test_getStatementsWithResponsesOnly_noResponse() {
        
        // Prepare
        let array = [
            ["%%response":
                ["paymentToken": "%%response.paymentToken"]
            ]
        ]
        
        // Execute
        let result = ApplicationServiceParser.getStatementsWithResponsesOnly(from: array)
        
        // Test
        XCTAssertEqual(result.count, 1)
    }
    
    func test_getStatementsWithResponsesOnly_noResponseStatements() {
        
        // Prepare
        let array = [
            ["something-but-not-response":
                ["paymentToken": "%%response.paymentToken"]
            ]
        ]
        
        // Execute
        let result = ApplicationServiceParser.getStatementsWithResponsesOnly(from: array)
        
        // Test
        XCTAssertEqual(result.count, 0)
    }
    
    func test_getStatementsWithResponsesOnly_twoResponses() {
        
        // Prepare
        let array = [
            ["%%response.paymentToken":
                ["paymentToken": "%%response.paymentToken"]
            ],
            ["%%response.somethingElse":
                ["paymentToken": "%%response.paymentToken"]
            ],
            ["not-a-response.somethingElse":
                ["paymentToken": "%%response.paymentToken"]
            ]
        ]
        
        // Execute
        let result = ApplicationServiceParser.getStatementsWithResponsesOnly(from: array)
        
        // Test
        XCTAssertEqual(result.count, 2)
    }
    
    func test_getStatementsWithResponsesOnly_twoResponsesInOne() {
        
        // Prepare
        let array = [
            ["%%response.paymentToken,%%response.somethingElse":
                ["paymentToken": "%%response.paymentToken"]
            ],
            ["%%response.somethingTotallyDifferent":
                ["paymentToken": "%%response.paymentToken"]
            ],
            ["not-a-response.somethingElse":
                ["paymentToken": "%%response.paymentToken"]
            ]
        ]
        
        // Execute
        let result = ApplicationServiceParser.getStatementsWithResponsesOnly(from: array)
        
        // Test
        XCTAssertEqual(result.count, 2)
    }
    
    func test_getStatementsWithResponsesOnly_twoResponsesInOneOneValid () {
        
        // Prepare
        let array = [
            ["%%response.paymentToken,%%not-a-response.somethingElse":
                ["paymentToken": "%%response.paymentToken"]
            ],
            ["%%response.somethingTotallyDifferent":
                ["paymentToken": "%%response.paymentToken"]
            ],
            ["not-a-response.somethingElse":
                ["paymentToken": "%%response.paymentToken"]
            ]
        ]
        
        // Execute
        let result = ApplicationServiceParser.getStatementsWithResponsesOnly(from: array)
        
        // Test
        XCTAssertEqual(result.count, 2)
    }
    
    func test_getStatementsWithResponsesOnly_allResponsesInvalid () {
        
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
        
        // Execute
        let result = ApplicationServiceParser.getStatementsWithResponsesOnly(from: array)
        
        // Test
        XCTAssertEqual(result.count, 0)
    }
    
    func test_getResponseMatchingStatements_allNonMatching() {
        
        // Prepare
        let array = [
            ["%%response.paymentToken,%%response.somethingElse":
                ["paymentToken": "%%response.paymentToken"]
            ],
            ["%%response.somethingTotallyDifferent":
                ["paymentToken": "%%response.paymentToken"]
            ],
        ]
        let response: [String: Any]  = ["paymentToken": "1234", "amount": 100]
        
        // Execute
        let result = ApplicationServiceParser.getResponseMatchingStatements(from: array, response: response)
        
        // Test
        XCTAssertEqual(result?.count, 0)
    }
    
    func test_getResponseMatchingStatements_oneMatching() {
        
        // Prepare
        let array = [
            ["%%response.paymentToken,%%response.somethingElse":
                ["paymentToken": "%%response.paymentToken"]
            ],
            ["%%response.paymentToken":
                ["paymentToken": "%%response.paymentToken"]
            ],
            ]
        let response: [String: Any]  = ["paymentToken": "1234", "amount": 100]
        
        // Execute
        let result = ApplicationServiceParser.getResponseMatchingStatements(from: array, response: response)
        
        // Test
        XCTAssertEqual(result?.count, 1)
    }
    
    func test_getResponseMatchingStatements_oneDoubleMatching() {
        
        // Prepare
        let array = [
            ["%%response.paymentToken,%%response.amount":
                ["paymentToken": "%%response.paymentToken"]
            ],
            ["%%response.something-else":
                ["paymentToken": "%%response.paymentToken"]
            ],
            ]
        let response: [String: Any]  = ["paymentToken": "1234", "amount": 100]
        
        // Execute
        let result = ApplicationServiceParser.getResponseMatchingStatements(from: array, response: response)
        
        // Test
        XCTAssertEqual(result?.count, 1)
    }
    
    // MARK: Checking type of collection against expected types
 
    func test_isStatementOfServiceParametersAssingments_noParameters() {
        
        // Prepare
        let statements = [String: Any]()
        
        // Execute
        let result = ApplicationServiceParser.isStatementOfServiceParametersAssingments(from: statements)
        
        // Test
        XCTAssertFalse(result)
    }
    
    func test_isStatementOfServiceParametersAssingments_wrongParameters() {
        
        // Prepare
        let statements = ["paymentToken": "%%response.paymentToken",
                          "amount": "%%response.amount"]
        
        // Execute
        let result = ApplicationServiceParser.isStatementOfServiceParametersAssingments(from: statements)
        
        // Test
        XCTAssertFalse(result)
    }
    
    func test_isStatementOfServiceParametersAssingments_oneWrongParameters() {
        
        // Prepare
        let statements = ["##paymentToken": "%%response.paymentToken",
                          "amount": "%%response.amount"]
        
        // Execute
        let result = ApplicationServiceParser.isStatementOfServiceParametersAssingments(from: statements)
        
        // Test
        XCTAssertFalse(result)
    }
    
    func test_isStatementOfServiceParametersAssingments_allRightParameters() {
        
        // Prepare
        let statements = ["##paymentToken": "%%response.paymentToken",
                          "##amount": "%%response.amount"]
        
        // Execute
        let result = ApplicationServiceParser.isStatementOfServiceParametersAssingments(from: statements)
        
        // Test
        XCTAssertTrue(result)
    }
    
    func test_isStatementRecursedServiceCall_wrongService() {
        
        // Prepare
        let statements = ["@@pay":
                            ["##paymentToken": "%%response.paymentToken"]
                        ]
        
        // Execute
        let result = ApplicationServiceParser.isStatementRecursedServiceCall(from: statements, serviceName: "@@not-pay")
        
        // Test
        XCTAssertFalse(result)
    }
    
    func test_isStatementRecursedServiceCall_matchService() {
        
        // Prepare
        let statements = ["@@pay":
            ["##paymentToken": "%%response.paymentToken"]
        ]
        
        // Execute
        let result = ApplicationServiceParser.isStatementRecursedServiceCall(from: statements, serviceName: "@@pay")
        
        // Test
        XCTAssertTrue(result)
    }
    
    func test_isStatementRecursedServiceCall_emptyService() {
        
        // Prepare
        let statements = ["@@pay":
            ["##paymentToken": "%%response.paymentToken"]
        ]
        
        // Execute
        let result = ApplicationServiceParser.isStatementRecursedServiceCall(from: statements, serviceName: "")
        
        // Test
        XCTAssertFalse(result)
    }
    
    func test_isStatementOpenModule_emptyService() {
        
        // Prepare
        let statements = [String: Any]()
        
        // Execute
        let result = ApplicationServiceParser.isStatementOpenModule(from: statements)
        
        // Test
        XCTAssertFalse(result)
    }
    
    func test_isStatementOpenModule_moreThanOneParameter() {
        
        // Prepare
        let statements =
            ["%%open":
                ["%%module": "module-name",
                 "%%method": "module-name",
                 "%%callback": ["paymentToken": "%%response.paymentToken"
                ]
            ],
            "%%another-parameter":
                ["paymentToken": "%%response.paymentToken"]
            ]
        
        // Execute
        let result = ApplicationServiceParser.isStatementOpenModule(from: statements)
        
        // Test
        XCTAssertFalse(result)
    }
    
    func test_isStatementOpenModule_validOpen() {
        
        // Prepare
        let statements =
            ["%%open":
                ["%%module": "module-name",
                 "%%method": "module-name",
                 "%%callback": ["paymentToken", "%%response.paymentToken"
                    ]
                ]
            ]
        
        // Execute
        let result = ApplicationServiceParser.isStatementOpenModule(from: statements)
        
        // Test
        XCTAssertTrue(result)
    }
    
    func test_isStatementOpenModule_nonValidOpen() {
        
        // Prepare
        let statements =
            ["%%no-open":
                ["%%module": "module-name",
                 "%%method": "module-name",
                 "%%callback": ["paymentToken", "%%response.paymentToken"
                    ]
                ]
        ]
        
        // Execute
        let result = ApplicationServiceParser.isStatementOpenModule(from: statements)
        
        // Test
        XCTAssertFalse(result)
    }
    
    func test_isStatementOpenModule_callbackParametersMissing() {
        
        // Prepare
        let statements =
            ["%%open":
                ["%%module": "module-name",
                 "%%method": "module-name"
                ]
        ]
        
        // Execute
        let result = ApplicationServiceParser.isStatementOpenModule(from: statements)
        
        // Test
        XCTAssertFalse(result)
    }
    
    func test_isStatementOpenModule_allParameters() {
        
        // Prepare
        let statements =
            ["%%open":
                ["%%module": "module-name",
                 "%%method": "module-name",
                 "%%callback": ["paymentToken","%%response.paymentToken"],
                 "%%parameters": ["paymentToken": "%%response.paymentToken"]
                ]
        ]
        
        // Execute
        let result = ApplicationServiceParser.isStatementOpenModule(from: statements)
        
        // Test
        XCTAssertTrue(result)
    }
    
    func test_isStatementError_noStatements() {
        
        // Prepare
        let statements = [String: Any]()
        
        // Execute
        let result = ApplicationServiceParser.isStatementError(from: statements)
        
        // Test
        XCTAssertFalse(result)
    }
    
    func test_isStatementError_moreThanOneParameter() {
        
        // Prepare
        let statements =
            ["%%error":
                ["%%module": "module-name",
                 "%%method": "module-name",
                 "%%callback": ["paymentToken": "%%response.paymentToken"
                    ]
                ],
             "%%another-parameter":
                ["paymentToken": "%%response.paymentToken"]
        ]
        
        // Execute
        let result = ApplicationServiceParser.isStatementError(from: statements)
        
        // Test
        XCTAssertFalse(result)
    }
    
    func test_isStatementError_notDictionaryButArray() {
        
        // Prepare
        let statements = [
                            "%%error":
                                ["401", "500"]
                         ]
        
        // Execute
        let result = ApplicationServiceParser.isStatementError(from: statements)
        
        // Test
        XCTAssertFalse(result)
    }
    
    func test_isStatementError_valis() {
        
        // Prepare
        let statements = [
            "%%error":
                ["401,500":  ["paymentToken": "%%response.paymentToken"],
                 "403":  ["paymentToken": "%%response.paymentToken"]
                ]
        ]
        
        // Execute
        let result = ApplicationServiceParser.isStatementError(from: statements)
        
        // Test
        XCTAssertTrue(result)
    }
    
    // MARK: getUrl tests
    
    func test_getUrl_noStatements() {
        
        // Prepare
        let statements = [String: Any]()
        
        // Execute
        let result = ApplicationServiceParser.getUrl(from: statements, schema: "yourbank")
        
        // Test
        XCTAssertNil(result)
    }
    
    func test_getUrl_validStatements() {
        
        // Prepare
        let statements: [String : Any] = ["%%open":
                                            ["%%module": "payments",
                                            "%%method": "/pay",
                                            "%%parameters": [
                                                "amount": "##amount",
                                                "token": "##paymentToken",
                                                "presentationMode": "navigationStack",
                                                "viewController": "PaymentsViewControllerId"
                                            ],
                                            "%%callback": [:]]
                                          ]
        
        // Execute
        let result = ApplicationServiceParser.getUrl(from: statements, schema: "yourbank")
        
        // Test
        XCTAssertNotNil(result)
    }
    
    func test_getUrl_validStatements_noSchema() {
        
        // Prepare
        let statements: [String : Any] = ["%%open":
            ["%%module": "payments",
             "%%method": "/pay",
             "%%parameters": [
                "amount": "##amount",
                "token": "##paymentToken",
                "presentationMode": "navigationStack",
                "viewController": "PaymentsViewControllerId"
                ],
            "%%callback": [:]]
        ]
        
        // Execute
        let result = ApplicationServiceParser.getUrl(from: statements, schema: "")
        
        // Test
        XCTAssertNil(result)
    }
    
    func test_getUrl_noOpen() {
        
        // Prepare
        let statements: [String : Any] = ["%%no-open":
            ["%%module": "payments",
             "%%method": "/pay",
             "%%parameters": [
                "amount": "##amount",
                "token": "##paymentToken",
                "presentationMode": "navigationStack",
                "viewController": "PaymentsViewControllerId"
                ],
             "%%callback": [:]]
        ]
        
        // Execute
        let result = ApplicationServiceParser.getUrl(from: statements, schema: "yourbank")
        
        // Test
        XCTAssertNil(result)
    }
    
    func test_getUrl_noParameters() {
        
        // Prepare
        let statements: [String : Any] = ["%%open":
            ["%%module": "payments",
             "%%method": "/pay",
             "%%callback": [:]]
        ]
        
        // Execute
        let result = ApplicationServiceParser.getUrl(from: statements, schema: "yourbank")
        
        // Test
        XCTAssertNotNil(result)
    }
    
    // MARK: getErrorMatchingStatements getting statements if error matches a parameter
    
    func test_getErrorMatchingStatements_noErrorStatement() {
        
        // Prepare
        let statements: [String : Any] = ["not-an-error": [:]]
        let errorCode = 400
        
        // Execute
        let result = ApplicationServiceParser.getErrorMatchingStatements(from: statements, errorCode: errorCode)
        
        // Test
        XCTAssertNil(result)
        
    }
    
    func test_getErrorMatchingStatements_noMatchingErrorCode() {
        
        // Prepare
        let statements: [String : Any] = ["401": [:]]
        let errorCode = 400
        
        // Execute
        let result = ApplicationServiceParser.getErrorMatchingStatements(from: statements, errorCode: errorCode)
        
        // Test
        XCTAssertNil(result)
        
    }
    
    func test_getErrorMatchingStatements_noMatchingStatementType() {
        
        // Prepare
        let statements: [String : Any] = ["400": ["something": "should-be-array"]]
        let errorCode = 400
        
        // Execute
        let result = ApplicationServiceParser.getErrorMatchingStatements(from: statements, errorCode: errorCode)
        
        // Test
        XCTAssertNil(result)
        
    }
    
    func test_getErrorMatchingStatements_singleMatchingStatement() {
        
        // Prepare
        let statements: [String : Any] = ["400": [["something": "should-be-array"]]]
        let errorCode = 400
        
        // Execute
        let result = ApplicationServiceParser.getErrorMatchingStatements(from: statements, errorCode: errorCode)
        
        // Test
        XCTAssertNotNil(result)
        
    }
    
    func test_getErrorMatchingStatements_twoMatchingStatement_onlyFirstTaken() {
        
        // Prepare
        let statements: [String : Any] = ["400": [["something400": "should-be-array"]],
                                          "401": [["something4001": "should-be-array"]]]
        let errorCode = 400
        
        // Execute
        let result = ApplicationServiceParser.getErrorMatchingStatements(from: statements, errorCode: errorCode)
        
        // Test
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.count, 1)
        XCTAssertEqual(result?.first?.keys.first, "something400")
    }
}

