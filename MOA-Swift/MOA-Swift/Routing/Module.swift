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

/**
 Application module represents a group off all the classes that implement a certain functionality of the module, like:
 
 - Storyboard
 - View Controllers
 - Views, specific to the module
 - Presenters, View Models and other Client architecture classes
 - ...
 
 Every module needs to identify itself with unique application route/domain which is queried by `ModuleHub`
 */
public final class Module<T: DependenciesProvider> {
    /**
     parameters:
     route:
        The route, domain, like _"/module-name"_

     routables:
        This array contains all the potential types module can let to route to.
    */
    public required init(route: String, routable: Routable<T>.Type) {
        self.route = route
        self.routableType = routable
    }

    let route: String
    let routableType: Routable<T>.Type
    var instantiatedRoutable: Routable<T>?
}

extension Module {
    func open(parameters: ModuleParameters, dependenciesProvider: T, path: String?, callback: @escaping ModuleCallback) {
        if let routable = instantiatedRoutable {
            routable.route(
                parameters: parameters,
                dependenciesProvider: dependenciesProvider,
                path: path,
                callback: callback
            )
        } else {
            let routable = routableType.init()
            instantiatedRoutable = routable
            routable.route(
                parameters: parameters,
                dependenciesProvider: dependenciesProvider,
                path: path,
                callback: callback
            )
        }
    }
}

/**
 class should be inherited by the classes, which are routed directly by a `Module` and be registered in it.
 */
open class Routable<T: DependenciesProvider> {

    /**
      instance of NavigationProvider logic, have to be used to present the UI elements of module
     */
    public let navigationProvider = NavigationProvider()

    public required init() {}
    /**
     Every class which wants to be routed by `Module` needs to identify itself with a certain path/method
     
     - returns:
        Collection of String that represents paths
     */
    open class var paths: [String] { fatalError() }

    /**
     Override this method to be routed by the module

     parameters:
     parameters:
        routing parameters, only primitive types is acceptable

     dependenciesProvider:
        a way to inject parameters from calling place to the routable

     path:
        used routing path

     callback: routing completion callback
    */
    open func route(
        parameters: ModuleParameters,
        dependenciesProvider: T,
        path: String?,
        callback: @escaping ModuleCallback
    ) { fatalError() }
}
