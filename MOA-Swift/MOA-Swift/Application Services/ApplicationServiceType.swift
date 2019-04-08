//
//  ApplicationServices.swift
//  ModuleArchitectureDemo
//
//  Created by Mladen Despotovic on 28.06.18.
//  Copyright © 2018 Mladen Despotovic. All rights reserved.
//

import Foundation

enum ValueType {
    
    case int
    case float
    case double
    case string
    case dictionary
    case array
    
    init?(_ value: Any) {
        
        switch value {
        case is Int:
            self = .int
        case is Float:
            self = .float
        case is Double:
            self = .double
        case is String:
            self = .string
        case is Dictionary<String,Any>:
            self = .dictionary
        case is Array<Any>:
            self = .array
        default:
            return nil
        }
    }
    
    var isNumber: Bool {
        return [.int, .float, .double].contains(self)
    }
    var isValue: Bool {
        return [.int, .float, .double, .string].contains(self)
    }
}

/**
 ApplicationServiceType instance represents execution of one single Use Case.
 It's based on execution steps from JSON file, which is passed by initialisation.
 */

internal struct Parser {
    
    struct Keywords {
        static let response = "%%response"
        static let serviceParameters = "%%serviceParameters"
        static let open = "%%open"
        static let callback = "%%callback"
        static let error = "%%error"
        static let module = "%%module"
        static let method = "%%method"
        static let parameters = "%%parameters"
    }
}

public protocol ApplicationServiceType: class {
    
    var serviceParameters: [String: Any] { get set }
    var service: [String: Any] {get set}
    var appRouter: ApplicationRouterType { get set }
    var scheme: String {get set}
    var serviceName: String? { get }
	var bundle: Bundle { get set }
    
	init?(jsonFilename: String?, bundle: Bundle)
    
    func loadService(jsonFilename: String) -> [String: Any]?
    func valid() -> Bool
    func run()
}

public extension ApplicationServiceType {
    
    var serviceName: String? {
        
        get {
            return service.keys.first(where: { $0.prefix(2) == "@@" })
        }
    }
    
    func valid() -> Bool {
        
        if service.count == 2,
            service.keys.contains(Parser.Keywords.serviceParameters),
            let serviceName = self.serviceName,
            let _ = service[serviceName] {
            
            return true
        }
        else { return false }
    }
    
    func loadService(jsonFilename: String) -> [String: Any]? {
		
		return bundle.loadJson(filename: jsonFilename)
    }

    func run() {
        
        guard let name = self.serviceName,
            let statementsArray = service[name] as?  [[String: Any]] else { return }
        
        execute(statements: statementsArray)
    }
    
    func execute(statements: [[String: Any]],
                 response: [String: Any]? = nil,
                 errorCode: Int? = nil) {
        
        statements.forEach { statement in
            
            if let errorCode = errorCode {
                executeError(statement: statement, errorCode: errorCode)
            }
            if let response = response {
                executeResponse(statement: statement, response: response)
                executeServiceParametersAssingments(statement: statement, response: response)
            }
            
            executeOpen(statement: statement)
        }
        
        
    }
    
    func executeOpen(statement: [String: Any]) {
        
        guard ApplicationServiceParser.isStatementOpenModule(from: statement),
            let url = ApplicationServiceParser.getUrl(from: statement, scheme: scheme),
            let openStatement = statement[Parser.Keywords.open] as? [String: Any],
            let callback = openStatement[Parser.Keywords.callback] as? [[String: Any]] else { return }
        
        appRouter.open(url: url) { (response, data, urlResponse, error) in
            
            if callback.count > 0 {
                self.execute(statements: callback, response: response, errorCode: error?.errorCode)
            }
        }
        return
    }
    
    func executeError(statement: [String: Any], errorCode: Int) {
        
        guard ApplicationServiceParser.isStatementError(from: statement),
            let statements = statement[Parser.Keywords.error] as? [String: Any],
            let errorMatchedStatements = ApplicationServiceParser.getErrorMatchingStatements(from: statements,
                                                                                             errorCode: errorCode) else { return }
        
        self.execute(statements: errorMatchedStatements,
                     response: nil,
                     errorCode: errorCode)
        
        return
    }
    
    func executeResponse(statement: [String: Any], response: [String: Any]) {
        
        guard ApplicationServiceParser.isStatementMatchingAnyResponse(from: statement,
                                                                      response: response),
            let statements = statement.first?.value as? [[String: Any]]  else { return }
        
        execute(statements: statements,
                response: response,
                errorCode: nil)
    }
    
    func executeServiceParametersAssingments(statement: [String: Any], response: [String: Any]) {
        
        guard ApplicationServiceParser.isStatementOfServiceParametersAssingments(from: statement) else { return }
        
        serviceParameters = ApplicationServiceParser.getResponseUpdatedServiceParameters(from: statement,
                                                                                         serviceParameters: serviceParameters,
                                                                                         response: response)
        
    }
    
    func executeServiceRecursively(statement: [String: Any], response: [String: Any]) {
        
        guard let serviceName = serviceName,
            ApplicationServiceParser.isStatementRecursedServiceCall(from: statement, serviceName: serviceName) else { return }
        
        if let serviceParameterAssingments = statement.first?.value as? [String: Any] {
            
            executeServiceParametersAssingments(statement: serviceParameterAssingments, response: response)
        }
        
        run()
    }
    
    // Assign the values to "##..." service parameters
    func assignValuesToServiceParameters(from array: [[String: Any]],
                                         response: [String: Any]) {
        
        let statementsWithResponsesOnly = ApplicationServiceParser.getStatementsWithResponsesOnly(from: array)
        guard let responseMatchingStatementsOnly = ApplicationServiceParser.getResponseMatchingStatements(from: statementsWithResponsesOnly,
                                                                                                          response: response) else { return }
        responseMatchingStatementsOnly.forEach { responseMatchingStatement in
            
            guard let key = responseMatchingStatement.keys.first,
                let value = responseMatchingStatement[key] as? [String: Any] else { return }
            serviceParameters = ApplicationServiceParser.getResponseUpdatedServiceParameters(from: value,
                                                                                             serviceParameters: serviceParameters,
                                                                                             response: response)
        }
    }
    
}

class ApplicationServiceParser {
    
    class func getParametersDictionaryForService(from array: [[String: Any]],
                                                 serviceName: String) -> [String: Any]? {
        
        // Isolate the dictionary under '@@...' service name as a key
        guard let serviceDictionary = array.reduce([String: Any](), { (current, dict) -> [String: Any]? in
            
            guard dict.count == 1,
                let dictFirstKey = dict.first?.key,
                dictFirstKey == serviceName else {
                    return nil
            }
            return dict[serviceName] as? [String: Any]
            
        }) else { return nil }
        
        let parametersDictionaryOnly = serviceDictionary.filter({ $0.key.prefix(2) == "##" })
        
        return parametersDictionaryOnly.count > 0 ? parametersDictionaryOnly : nil
    }
    
    class func getResponseUpdatedServiceParameters(from parametersDictionary: [String: Any],
                                                   serviceParameters: [String: Any],
                                                   response: [String: Any]) -> [String: Any] {
        
        guard parametersDictionary.count > 0,
            serviceParameters.count > 0,
            response.count > 0 else { return serviceParameters }
        
        // Create new parameters dictionary with values which correspond to values from 'response' dictionary
        var newServiceParameters = serviceParameters
        parametersDictionary.forEach { key, value in
            
            guard let stringValue = value as? String else { return }
            let valueSplits = stringValue.split(separator: ".")
            
            if ValueType(value)?.isNumber == true {
                newServiceParameters[key] = value
            }
            else if String(valueSplits.first ?? "") == Parser.Keywords.response && valueSplits.count == 2  {
                
                if let lastValue = valueSplits.last {
                    newServiceParameters[key] = response[String(lastValue)]
                }
            }
        }
        
        return newServiceParameters
    }
    
    class func getStatementsWithResponsesOnly(from array: [[String: Any]]) -> [[String: Any]] {
        
        let responseStatements = array.filter { $0.count == 1 }.filter { String(($0.first?.key.prefix(Parser.Keywords.response.count)) ?? "") == Parser.Keywords.response }
        let matchingResponseStatements = responseStatements.filter { response in
            
            if response[Parser.Keywords.response] != nil { return true }
            
            guard let responseComponents = response.keys.first?.split(separator: ","),
                responseStatements.count > 0 else { return false }
            let responseMatchingKeys = responseComponents.filter { $0.prefix(10) == Parser.Keywords.response }
            guard responseMatchingKeys.count > 0 else { return false }
            
            return true
        }
        return matchingResponseStatements
    }
    
    // Get back only statements that have the reponses and they are matching repsonses from parameter dictionary
    class func getResponseMatchingStatements(from array: [[String: Any]],
                                             response: [String: Any]) -> [[String: Any]]? {
        
        let responseStatements = ApplicationServiceParser.getStatementsWithResponsesOnly(from: array)
        
        let matchingResponseStatements = responseStatements.filter { responseDict in
            
            return ApplicationServiceParser.isStatementMatchingAnyResponse(from: responseDict,
                                                                           response: response)
        }
        
        return matchingResponseStatements
    }
    
    class func isStatementMatchingAnyResponse(from array: [String: Any],
                                              response: [String: Any]) -> Bool {
        
        if array[Parser.Keywords.response] != nil { return true }
        
        guard let responseComponents = array.keys.first?.split(separator: ",") else { return false }
        
        let keysFromResponseComponents = responseComponents.map { (responseComponent) -> String? in
            
            let responseSeparatedComponents = responseComponent.split(separator: ".")
            guard responseSeparatedComponents.count > 1,
                let key = responseSeparatedComponents.last else { return nil }
            
            return String(key)
            }.compactMap { $0 }
        
        for key in keysFromResponseComponents {
            
            if response[key] == nil {
                return false
            }
        }
        return true
    }
    
    
    class func isStatementOfServiceParametersAssingments(from dictionary: [String: Any]) -> Bool {
        
        let serviceParametertStatements = dictionary.filter { $0.key.prefix(2) == "##" }
        
        return serviceParametertStatements.count == dictionary.count && dictionary.count != 0
    }
    
    class func isStatementRecursedServiceCall(from dictionary: [String: Any],
                                              serviceName: String) -> Bool {
        
        guard dictionary.count == 1 else { return false }
        return dictionary.keys.first == serviceName
    }
    
    class func isStatementOpenModule(from dictionary: [String: Any]) -> Bool {
        
        guard dictionary.count == 1,
            let openParameters = dictionary[Parser.Keywords.open] as? [String: Any],
            openParameters.count > 2 && openParameters.count <= 4,
            let _ = openParameters[Parser.Keywords.module],
            let _ = openParameters[Parser.Keywords.method],
            let _ = openParameters[Parser.Keywords.callback] else { return false }
        
        if let parameters = openParameters[Parser.Keywords.parameters] as? [String: Any],
            parameters.count == 0 {
            
            return false
        }
        
        return true
    }
    
    class func isStatementError(from dictionary: [String: Any]) -> Bool {
        
        if dictionary.count == 1,
            let _ = dictionary[Parser.Keywords.error] as? [String: Any] {
            
            return true
        } else {
            return false
        }
    }
    
    // MARK:
    
    class func getUrl(from openStatement: [String: Any], scheme: String) -> URL? {
        
        if ApplicationServiceParser.isStatementOpenModule(from: openStatement),
            let statement = openStatement[Parser.Keywords.open] as? [String: Any],
            let host = statement[Parser.Keywords.module] as? String,
            let path = statement[Parser.Keywords.method] as? String {
            
            return URL(scheme: scheme,
                       host: host,
                       path: path,
                       parameters: statement[Parser.Keywords.parameters] as? [String: String])
        }
        return nil
    }
    
    class func getErrorMatchingStatements(from errorStatement: [String: Any], errorCode: Int) -> [[String: Any]]? {
        
        for errorDict in errorStatement {
            
            let errors = errorDict.key.split(separator: ",")
            let errorNumbers = errors.map { Int($0) }
            
            if errorNumbers.contains(errorCode) {
                
                return errorStatement[errorDict.key] as? [[String: Any]]
            }
        }
        
        return nil
    }
    
}

