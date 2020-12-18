//
//  IntentsStorageTests.swift
//  MOASwift
//
//  Created by Dmitry Poznukhov on 12.11.20.
//  Copyright © 2020 1und1. All rights reserved.
//

import XCTest
@testable import MOA_Swift

class IntentsStorageTests: XCTestCase {

    private var intentsStorage: IntentsStorage!
    private var fatalErrorUtil: FatalErrorUtilSpy!

    override func setUp() {
        fatalErrorUtil = FatalErrorUtilSpy()
        intentsStorage = IntentsStorage(fatalErrorUtil: fatalErrorUtil)
    }

    func test_PushModal() {
        let viewController = UIViewController()

        let id = intentsStorage.push(intent: .modal(viewController: viewController, presentationStyle: .currentContext))

        XCTAssertEqual(intentsStorage.intentContainers, [id: IntentContainer(view: nil, viewController: viewController, presentationStyle: .currentContext, window: nil, intent: .modal)])
    }

    func test_PushNavigation() {
        let viewController = UIViewController()

        let id = intentsStorage.push(intent: .push(viewController: viewController))

        XCTAssertEqual(intentsStorage.intentContainers, [id: IntentContainer(view: nil, viewController: viewController, presentationStyle: nil, window: nil, intent: .push)])
    }

    func test_PushNavigationRoot() {
        let viewController = UIViewController()

        let id = intentsStorage.push(intent: .rootInNavigation(viewController: viewController))

        XCTAssertEqual(intentsStorage.intentContainers, [id: IntentContainer(view: nil, viewController: viewController, presentationStyle: nil, window: nil, intent: .rootInNavigation)])
    }

    func test_PushEmbed() {
        let viewController = UIViewController()

        let id = intentsStorage.push(intent: .embed(view: viewController.view, viewController: viewController))

        XCTAssertEqual(intentsStorage.intentContainers, [id: IntentContainer(view: viewController.view, viewController: viewController, presentationStyle: nil, window: nil, intent: .embed)])
    }

    func test_PushRoot() {
        let window = UIWindow()

        let id = intentsStorage.push(intent: .root(window: window))

        XCTAssertEqual(intentsStorage.intentContainers, [id: IntentContainer(view: nil, viewController: nil, presentationStyle: nil, window: window, intent: .root)])
    }

    func test_PushID() {
        let viewController = UIViewController()

        let id1 = intentsStorage.push(intent: .modal(viewController: viewController, presentationStyle: .currentContext))
        let id2 = intentsStorage.push(intent: .modal(viewController: viewController, presentationStyle: .currentContext))
        let id3 = intentsStorage.push(intent: .modal(viewController: viewController, presentationStyle: .currentContext))

        let container = IntentContainer(view: nil, viewController: viewController, presentationStyle: .currentContext, window: nil, intent: .modal)
        XCTAssertEqual(intentsStorage.intentContainers, [id1: container, id2: container, id3: container])
    }

    func test_Pop() {
        let viewController = UIViewController()
        let id = intentsStorage.push(intent: .modal(viewController: viewController, presentationStyle: .currentContext))

        let intent = intentsStorage.pop(id: id)

        XCTAssert(intentsStorage.intentContainers.isEmpty)
        XCTAssertEqual(intent?.intentContainer, IntentContainer(view: nil, viewController: viewController, presentationStyle: .currentContext, window: nil, intent: .modal))
    }

    func test_PopTwice() {
        let viewController = UIViewController()
        let id = intentsStorage.push(intent: .modal(viewController: viewController, presentationStyle: .currentContext))
        _ = intentsStorage.pop(id: id)

        let intent2 = intentsStorage.pop(id: id)

        XCTAssertNil(intent2)
        XCTAssert(fatalErrorUtil.fatalErrorCalled)
    }
}

private final class FatalErrorUtilSpy: FatalErrorUtil {
    var fatalErrorCalled = false
    func fatalError() {
        fatalErrorCalled = true
    }
}

private extension Intent {
    var intentContainer: IntentContainer {
        switch self {
        case let .push(viewController):
            return IntentContainer(view: nil, viewController: viewController, presentationStyle: nil, window: nil, intent: .push)
        case let .rootInNavigation(viewController):
            return IntentContainer(view: nil, viewController: viewController, presentationStyle: nil, window: nil, intent: .rootInNavigation)
        case let .modal(viewController, presentationStyle):
            return IntentContainer(view: nil, viewController: viewController, presentationStyle: presentationStyle, window: nil, intent: .modal)
        case let .embed(view, viewController):
            return IntentContainer(view: view, viewController: viewController, presentationStyle: nil, window: nil, intent: .embed)
        case let .root(window):
            return IntentContainer(view: nil, viewController: nil, presentationStyle: nil, window: window, intent: .root)
        }
    }
}
