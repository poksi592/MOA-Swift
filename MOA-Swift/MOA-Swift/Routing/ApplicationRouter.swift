//
//  ApplicationRouter.swift
//  ModuleArchitectureDemo
//
//  Created by Mladen Despotovic on 14/05/2018.
//  Copyright © 2018 Mladen Despotovic. All rights reserved.
//

import Foundation

public typealias ModuleCallback = ([String: Any]?, URLResponse?, ResponseError?) -> Void

/**
 Protocol defines application router, which function is
 
 - register application modules
 - access/open the modules
 - provide the callback, result of the access
 */
public protocol ApplicationRouterType: class {
    
    var instantiatedModules: [ModuleType] { get set }
    var moduleQueue: DispatchQueue { get }
    
    func open(url: URL,
              injectedObjects: [String: Any]?,
              callback: ModuleCallback?)
}

public extension ApplicationRouterType {
    
    func open(url: URL,
              injectedObjects: [String: Any]? = nil,
              callback: ModuleCallback?) {
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let route = components.host else {
                return
        }
        
        guard let module = instantiatedModules.first(where: { $0.route == route }),
            let path = module.paths.first(where: { $0 == url.path }) else {
                
                assertionFailure("Wrong host or/and path")
                return
        }
        
        var parameters = components.queryItemsDictionary
        parameters?["url"] = url.absoluteString
        module.open(parameters: parameters,
                    path: path,
                    injectedObjects: injectedObjects) { (response, urlResponse, error) in
            
            callback?(response, urlResponse, error)
        }
        
    }
}

public class ApplicationRouter: ApplicationRouterType {
    
    // TODO: This is synchronising only write access, which might be inadequate in many cases
    // Need to be replaced with proper full generic implementation of synchronized collection
	private (set) public var moduleQueue = DispatchQueue(label: "com.yourapp.module.queue")
    
    // ApplicationRouter is a singleton, because it makes it easier to be accessed from anywhere to access its functions/services
    public static let shared = ApplicationRouter()
    
    // We instantiate Modules and add them to the array here...
	public var instantiatedModules: [ModuleType] = []
    
    public init() {}
}

@objc
public class URLRouter: URLProtocol, URLSessionDataDelegate, URLSessionTaskDelegate {
    
    // TODO: This is synchronisyng only write access, which might be inadequate in many cases
    // Need to be replaced with proper full generic implementation of synchronized collection
    private (set) var moduleQueue = DispatchQueue(label: "com.yourapp.module.queue.url-router")
    
    // MARK: URLProtocol methods overriding
    
	override public class func canInit(with task: URLSessionTask) -> Bool {
        
        // Check if there's internal app scheme that matches the one in the URL
        guard let url = task.originalRequest?.url,
            url.containsInAppScheme() else {
                return false
        }
        
        // Check if there's a path in the module that matches the one in the URL
        guard let module = ApplicationRouter.shared.instantiatedModules.first(where: { $0.route == task.originalRequest?.url?.host }),
            let _ = module.paths.first(where: { $0 == task.originalRequest?.url?.path }) else {
                return false
        }
        return true
    }
    
	override public class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    
	override public func startLoading() {
        
        guard let url = request.url else {
            return
        }
        
        ApplicationRouter.shared.open(url: url) { (response, urlResponse, error) in
            
            // TODO: Calling URLSessionDataDelegate methods to return the response
        }
    }
    
	override public func stopLoading() {
    }
}
