//
//  DefaultUIBridge.swift
//  iOSMailer
//
//  Created by Dmitry Poznukhov on 20.10.20.
//  Copyright © 2020 1&1. All rights reserved.
//

import UIKit

/**
 class encapsulate navigation logic,
 usage example:

 - parent module pushes the intent to the IntentsStorage
 - the IntentsStorage passed to the child module routable in the 'route' method
 - routable passes it to the module specific wireframe
 - wireframe creates view controller and passing it the Navigation provider
 - NavigationProvider pop the intent by id from IntentsStorage
 - NavigationProvider executes the intent

*/
public final class NavigationProvider {

    public init() {
        self.fatalErrorUtil = DefaultFatalErrorUtil()
    }

    init(fatalErrorUtil: FatalErrorUtil) {
        self.fatalErrorUtil = fatalErrorUtil
    }
    /**
     execute the navigation intent by intentID

     parameters:
     intentId: identifier received from 'intentsStorage.push()' method
     intentsStorage: the intentsStorage used to create intentID
     destinationViewController: child view controller which have to be presented with the intent
    */
    public func execute(intentId: String, from intentsStorage: IntentsStorage, to destinationViewController: UIViewController) {
        guard let intent = intentsStorage.pop(id: intentId) else {
            fatalErrorUtil.fatalError()
            return
        }
        switch intent {
        case let .push(viewController):
            let navigationController = (viewController as? UINavigationController) ?? viewController.navigationController
            navigationController?.pushViewController(destinationViewController, animated: true)
        case let .rootInNavigation(viewController):
            let navigationController = (viewController as? UINavigationController) ?? viewController.navigationController
            navigationController?.setViewControllers([destinationViewController], animated: true)
        case let .modal(viewController, presentationStyle):
            let navigationController = (destinationViewController as? UINavigationController) ?? UINavigationController(rootViewController: destinationViewController)
            viewController.modalPresentationStyle = presentationStyle
            viewController.present(navigationController, animated: true)
        case let .embed(view, viewController):
            destinationViewController.willMove(toParent: viewController)
            view.addSubview(destinationViewController.view)
            viewController.addChild(destinationViewController)
            destinationViewController.didMove(toParent: viewController)
            viewController.view.leftAnchor.constraint(equalTo: destinationViewController.view.leftAnchor).isActive = true
            viewController.view.topAnchor.constraint(equalTo: destinationViewController.view.topAnchor).isActive = true
            viewController.view.rightAnchor.constraint(equalTo: destinationViewController.view.rightAnchor).isActive = true
            viewController.view.bottomAnchor.constraint(equalTo: destinationViewController.view.bottomAnchor).isActive = true
        case let .root(window):
            window.rootViewController = destinationViewController
        }
    }

    private let fatalErrorUtil: FatalErrorUtil
}
