//
//  NavigationProviderTests.swift
//  MOASwift
//
//  Created by Dmitry Poznukhov on 12.11.20.
//  Copyright © 2020 1und1. All rights reserved.
//

import XCTest
@testable import MOA_Swift

class NavigationProviderTests: XCTestCase {

    private var navigationProvider: NavigationProvider!
    private var fatalErrorUtil: FatalErrorUtilSpy!

    override func setUp() {
        fatalErrorUtil = FatalErrorUtilSpy()
        navigationProvider = NavigationProvider(fatalErrorUtil: fatalErrorUtil)
    }

    func testExecuteInvalidIntent() {
        let intentsStorage = IntentsStorage(fatalErrorUtil: fatalErrorUtil)

        navigationProvider.execute(intentId: "12", from: intentsStorage, to: UIViewController())

        XCTAssert(fatalErrorUtil.fatalErrorCalled)
    }

    func testExecuteModalNotWrapped() {
        let intentsStorage = IntentsStorage(fatalErrorUtil: fatalErrorUtil)
        let viewController = UIViewControllerMock()
        let id = intentsStorage.push(intent: .modal(viewController: viewController, presentationStyle: .currentContext))
        let destinationViewController = UIViewController()

        navigationProvider.execute(intentId: id, from: intentsStorage, to: destinationViewController)

        XCTAssertEqual((viewController.lastModalViewController as! UINavigationController).viewControllers, [destinationViewController])
    }

    func testExecuteModalWrapped() {
        let intentsStorage = IntentsStorage(fatalErrorUtil: fatalErrorUtil)
        let viewController = UIViewControllerMock()
        let id = intentsStorage.push(intent: .modal(viewController: viewController, presentationStyle: .currentContext))
        let destinationViewController = UINavigationController(rootViewController: UIViewController())

        navigationProvider.execute(intentId: id, from: intentsStorage, to: destinationViewController)

        XCTAssertEqual(viewController.lastModalViewController, destinationViewController)
    }

    func testExecutePush() {
        let intentsStorage = IntentsStorage(fatalErrorUtil: fatalErrorUtil)
        let viewController = UIViewControllerMock()
        let id = intentsStorage.push(intent: .push(viewController: viewController))
        let destinationViewController = UIViewController()

        navigationProvider.execute(intentId: id, from: intentsStorage, to: destinationViewController)

        XCTAssertEqual(viewController.navigationContrtollerMock.lastPushedViewController, destinationViewController)
    }

    func testExecuteNavigationRoot() {
        let intentsStorage = IntentsStorage(fatalErrorUtil: fatalErrorUtil)
        let viewController = UIViewControllerMock()
        let id = intentsStorage.push(intent: .rootInNavigation(viewController: viewController))
        let destinationViewController = UIViewController()

        navigationProvider.execute(intentId: id, from: intentsStorage, to: destinationViewController)

        XCTAssertEqual(viewController.navigationContrtollerMock.lastNewListOfViewControllers, [destinationViewController])
    }

    func testExecuteEmbed() {
        let intentsStorage = IntentsStorage(fatalErrorUtil: fatalErrorUtil)
        let viewController = UIViewController()
        let id = intentsStorage.push(intent: .embed(view: viewController.view, viewController: viewController))
        let destinationViewController = UIViewController()

        navigationProvider.execute(intentId: id, from: intentsStorage, to: destinationViewController)

        XCTAssertEqual(viewController.children.first, destinationViewController)
        XCTAssertEqual(viewController.view.subviews.first, destinationViewController.view)
    }

    func testExecuteRoot() {
        let intentsStorage = IntentsStorage(fatalErrorUtil: fatalErrorUtil)
        let window = UIWindow()
        let id = intentsStorage.push(intent: .root(window: window))
        let destinationViewController = UIViewController()

        navigationProvider.execute(intentId: id, from: intentsStorage, to: destinationViewController)

        XCTAssertEqual(window.rootViewController, destinationViewController)
    }
}

private final class FatalErrorUtilSpy: FatalErrorUtil {
    var fatalErrorCalled = false
    func fatalError() {
        fatalErrorCalled = true
    }
}

private final class UIViewControllerMock: UIViewController {
    var lastModalViewController: UIViewController?
    let navigationContrtollerMock = NavigationContrtollerMock()

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        lastModalViewController = viewControllerToPresent
    }

    override var navigationController: UINavigationController? { navigationContrtollerMock }
}

private final class NavigationContrtollerMock: UINavigationController {
    var lastPushedViewController: UIViewController?
    var lastNewListOfViewControllers: [UIViewController] = []

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        lastPushedViewController = viewController
    }

    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        lastNewListOfViewControllers = viewControllers
    }
}
