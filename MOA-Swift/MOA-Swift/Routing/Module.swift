//
//  Module.swift
//  ModuleArchitectureDemo
//
//  Created by Mladen Despotovic on 29.06.18.
//  Copyright © 2018 Mladen Despotovic. All rights reserved.
//

import Foundation
import UIKit

public typealias ModuleParameters = [String: Any]

public struct ModuleConstants {
    
    struct UrlParameter {
        
        static let viewController = "viewController"
        static let presentationMode = "presentationMode"
        static let storyboard = "storyboard"
    }
}

public enum ResponseError: Error {
    
    case serializationFailed
    case taskCancelled
    case badRequest400(error: Error?)
    case unauthorized401(error: Error?)
    case forbidden403(error: Error?)
    case notFound404(error: Error?)
    case other400(error: Error?)
    case serverError500(error: Error?)
    case other
    
    var errorCode: Int? {
        
        get {
            
            switch self {
            case .badRequest400:
                return 400
            case .unauthorized401:
                return 401
            case .forbidden403:
                return 403
            case .notFound404:
                return 404
            case .other400:
                return 405
            case .serverError500:
                return 500
            default:
                return nil
            }
        }
    }
    
    public init?(error: Error?, response: HTTPURLResponse?, code: Int? = nil) {
        
        let responseCode: Int
        if let response = response {
            responseCode = response.statusCode
        } else if let code = code {
            responseCode = code
        } else {
            responseCode = 0
            self = .other
        }
        
        switch responseCode {
        case 200..<300:
            return nil
        case 400:
            self = .badRequest400(error: error)
        case 401:
            self = .unauthorized401(error: error)
        case 403:
            self = .forbidden403(error: error)
        case 404:
            self = .notFound404(error: error)
        case 405..<500:
            self = .other400(error: error)
        case 500..<600:
            self = .serverError500(error: error)
        default:
            self = .other
        }
    }
}

/**
 Application module represents a group off all the classes that implement a certain functionality of the module, like:
 
 - Storyboard
 - View Controllers
 - Views, specific to the module
 - Presenters, View Models and other Client architecture classes
 - ...
 
 Every module needs to identify itself with unique application route/domain which is queried by `ModuleHub`
 */
public protocol ModuleType: class {
    
    /**
     Every module needs to identify itself with a certain route/domain
     
     - returns:
     String that represents the route, domain, like _"/module-name"_
     */
    var route: String { get }
    
    /**
     Paths, which represent methods/functionalities a module has, module capabilities, actually
     
     - returns:
     Array of path strings
     */
    var paths: [String] { get }
    
    /**
     This array contains all the potential types module can let to route to.
     Reflection is used for memory savvy approach
     */
    var subscribedRoutables: [ModuleRoutable.Type] { get }
    var instantiatedRoutables: [WeakContainer<ModuleRoutable>] { get set }
    
    /**
     Function has to implement start of the module
     
     - parameters:
     - parameters: Simple dictionary of parameters
     - path: Path which is later recognised by specific module and converted to possible method
     */
    func open(parameters: ModuleParameters?,
              path: String?,
              injectedObjects: [String: Any]?,
              callback: ModuleCallback?)
}

public extension ModuleType {
    
    func open(parameters: ModuleParameters?,
              path: String?,
              injectedObjects: [String: Any]? = nil,
              callback: ModuleCallback?) {
        
        guard let subscribedRoutableType = subscribedRoutables.first(where: { subscribedType in
            
            let matchedType = subscribedType.getPaths().first(where: { $0 == path })
            return matchedType != nil
        }) else { return }
        
        // Flush empty weak containers in 'instantiatedRoutables'
        instantiatedRoutables = instantiatedRoutables.map { routable in
            if routable.value == nil {
                return nil
            }
            else {
                return routable
            }
        }.compactMap { $0 }
        
        let routable = instantiatedRoutables.first(where: { routable in
            return subscribedRoutableType == type(of: routable.value!)
        })
        
        if let routable = routable?.value {
            routable.route(parameters: parameters,
                           path: path,
                           injectedObjects: injectedObjects,
                           callback: callback)
        }
        else {
            let routable = subscribedRoutableType.routable()
            instantiatedRoutables.append(WeakContainer(value: routable))
            routable.route(parameters: parameters,
                           path: path,
                           injectedObjects: injectedObjects,
                           callback: callback)
        }
    }
}

/**
 Protocol should be adopted by the classes, which are routed directly by a `Module` and
 be registered in it.
 */
public protocol ModuleRoutable: class {

    /**
     Every class which wants to be routed by `Module` needs to identify itself with a certain path/method
     
     - returns:
     Collection of String that represents paths
     */
    static func getPaths() -> [String]
    
    /**
     Function which is a workaround for the weak reflection possibilites to
     create an instance of `ModuleRoutable` from `Class.Type`
     */
    static func routable() -> ModuleRoutable
    
    func route(parameters: ModuleParameters?,
               path: String?,
               injectedObjects: [String: Any]?,
               callback: ModuleCallback?)
}

public class StoryboardIdentifiableViewController: UIViewController {
    
    var storyboardId: String? = nil
}

public protocol RoutableViewControllerType where Self: UIViewController {
    
    var presenter: ModulePresentable? { get set }
}

public protocol ModulePresentable: class {
    
}







