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
 This protocol have to be used to Generic type of ApplicationRouter
 */
public protocol DependenciesProvider {

    /**
     any call to module providing UI have to provide intenID received from shared DependenciesProvider.intentsStorage between modules.
     */
    var intentsStorage: IntentsStorage { get }
}

/**
class defines application router, which function is

- register application modules
- unregister application modules
- access/open the modules
- provide the callback, result of the access
*/
public final class ApplicationRouter<T: DependenciesProvider> {
    /**
     initializer

     parameters:
     modules:
        list of modules to route to
    */
    public init(_ modules: Module<T>...) {
        self.modules = modules
    }

    /**
     route application to specific route

     parameters:
     url:
        routed url

     dependenciesProvider:
        a way to inject parameters from calling place to the routable

     callback: routing completion callback
    */
    public func open(url: URL, dependenciesProvider: T, callback: @escaping ModuleCallback) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }
        guard let route = components.host else { return }
        guard let module = (modules.first { $0.route == route }) else { return assertionFailure("Wrong host or/and path") }
        guard let path = (module.routableType.paths.first { $0 == url.path }) else { return assertionFailure("Wrong host or/and path") }

        var parameters = components.queryItemsDictionary
        parameters["url"] = url.absoluteString
        module.open(parameters: parameters, dependenciesProvider: dependenciesProvider, path: path, callback: callback)
    }

    let modules: [Module<T>]
}
