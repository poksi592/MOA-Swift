//
//  UIBridge.swift
//  iOSMailer
//
//  Created by Dmitry Poznukhov on 20.10.20.
//  Copyright © 2020 1&1. All rights reserved.
//

import UIKit

/**
 enum defines the way how one or another module intended to be presented

 -push: push to the navigation stack
 -modal: present modally
 -embed: embed in the parent view/viewController
 -root: replace root view controller of provided window

*/
public enum Intent {
    case push(viewController: UIViewController)
    case rootInNavigation(viewController: UIViewController)
    case modal(viewController: UIViewController, presentationStyle: UIModalPresentationStyle)
    case embed(view: UIView, viewController: UIViewController)
    case root(window: UIWindow)
}

/**
 class defines bridge connecting independent modules
 have to be used if one module need to present another one, for this:

 - parent module pushes the intent to the IntentsStorage
 - the IntentsStorage passed to the child module routable in the 'route' method
 - routable passes it to the module specific wireframe
 - wireframe creates view controller and passing it the Navigation provider
 - NavigationProvider pop the intent by id from IntentsStorage
 - NavigationProvider executes the intent

*/
public final class IntentsStorage {

    public init() {
        self.fatalErrorUtil = DefaultFatalErrorUtil()
    }

    init(fatalErrorUtil: FatalErrorUtil) {
        self.fatalErrorUtil = fatalErrorUtil
    }

    /**
     store the intent in the storage, all values passed with intent are stored by weak reference
     parameters:
     intent: enum case of expected navigation
    */
    public func push(intent: Intent) -> String {
        let id = UUID().uuidString
        switch intent {
        case let .push(viewController):
            intentContainers[id] = IntentContainer(view: nil, viewController: viewController, presentationStyle: nil, window: nil, intent: .push)
        case let .rootInNavigation(viewController):
            intentContainers[id] = IntentContainer(view: nil, viewController: viewController, presentationStyle: nil, window: nil, intent: .rootInNavigation)
        case let .modal(viewController, presentationStyle):
            intentContainers[id] = IntentContainer(view: nil, viewController: viewController, presentationStyle: presentationStyle, window: nil, intent: .modal)
        case let .embed(view, viewController):
            intentContainers[id] = IntentContainer(view: view, viewController: viewController, presentationStyle: nil, window: nil, intent: .embed)
        case let .root(window):
            intentContainers[id] = IntentContainer(view: nil, viewController: nil, presentationStyle: nil, window: window, intent: .root)
        }
        return id
    }

    /**
     fetch early stored intent by the intentID, operation is destructive, one intent can be popped only once
     parameters:
     id: the intentID received from 'push' method
    */
    func pop(id: String) -> Intent? {
        guard let container = intentContainers[id] else {
            fatalErrorUtil.fatalError()
            return nil
        }
        intentContainers.removeValue(forKey: id)
        switch container.intent {
        case .push:
            guard let viewController = container.viewController else {
                fatalErrorUtil.fatalError()
                return nil
            }
            return .push(viewController: viewController)
        case .rootInNavigation:
            guard let viewController = container.viewController else {
                fatalErrorUtil.fatalError()
                return nil
            }
            return .rootInNavigation(viewController: viewController)
        case .modal:
            guard let viewController = container.viewController, let presentationStyle = container.presentationStyle else {
                fatalErrorUtil.fatalError()
                return nil
            }
            return .modal(viewController: viewController, presentationStyle: presentationStyle)
        case .embed:
            guard let viewController = container.viewController, let view = container.view else {
                fatalErrorUtil.fatalError()
                return nil
            }
            return .embed(view: view, viewController: viewController)
        case .root:
            guard let window = container.window else {
                fatalErrorUtil.fatalError()
                return nil
            }
            return .root(window: window)
        }
    }

    var intentContainers: [String: IntentContainer] = [:]
    private let fatalErrorUtil: FatalErrorUtil
}

final class IntentContainer: Equatable {
    weak var view: UIView?
    weak var viewController: UIViewController?
    let presentationStyle: UIModalPresentationStyle?
    weak var window: UIWindow?
    let intent: Intent

    enum Intent {
        case push
        case rootInNavigation
        case modal
        case embed
        case root
    }

    init(view: UIView?, viewController: UIViewController?, presentationStyle: UIModalPresentationStyle?, window: UIWindow?, intent: Intent) {
        self.view = view
        self.viewController = viewController
        self.presentationStyle = presentationStyle
        self.window = window
        self.intent = intent
    }

    static func == (lhs: IntentContainer, rhs: IntentContainer) -> Bool {
        lhs.view == rhs.view && lhs.viewController == rhs.viewController && lhs.window == rhs.window && lhs.intent == rhs.intent && lhs.presentationStyle == rhs.presentationStyle
    }
}
