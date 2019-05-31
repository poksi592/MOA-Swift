//
//  WireframeTypeTests.swift
//  MOA-SwiftTests
//
//  Created by Mladen Despotovic on 03.04.19.
//  Copyright © 2019 Mladen Despotovic. All rights reserved.
//

import XCTest
@testable import MOA_Swift

class WireframeTypeTests: XCTestCase {
    
    func test_setupWireframeStoryboardParameter() {
        
        // Prepare
        let wireframe = MockWireframe(application: UIApplication.shared)
        let storyboard1 = wireframe.storyboard
        
        // Execute
        wireframe.setupWireframe(parameters: [ModuleConstants.UrlParameter.storyboard: "MockStoryboard"],
                                 bundle: Bundle(for: WireframeTypeTests.self))
        let storyboard2 = wireframe.storyboard
        
        // Test
        XCTAssertNotEqual(storyboard1, storyboard2)
    }
    
    func test_setupWireframeInitialVcParameter() {
        
        // Prepare
        let wireframe = MockWireframe(application: UIApplication.shared)
        
        // Execute
        wireframe.setupWireframe(parameters: [ModuleConstants.UrlParameter.viewController: "topVc"],
                                 bundle: Bundle(for: WireframeTypeTests.self))
        
        // Test
        XCTAssertEqual(wireframe.presentedViewControllers.count, 1)
    }

    func test_viewControllerFromParametersNone() {
        
        // Prepare
        let wireframe = MockWireframe(application: UIApplication.shared)
        
        // Execute
        let vc = wireframe.viewController(from: nil)
        
        // Test
        XCTAssertNil(vc)
    }
    
    func test_viewControllerFromParameters() {
        
        // Prepare
        let wireframe = MockWireframe(application: UIApplication.shared)
        
        // Execute
        let vc = wireframe.viewController(from: [ModuleConstants.UrlParameter.viewController: "topVc"])
        
        // Test
        XCTAssertNotNil(vc)
    }
    
    func test_setPresentationModeNoParams() {
        
        let wireframe = MockWireframe(application: UIApplication.shared)
        wireframe.setPresentationMode(from: nil)
        
        if case .root = wireframe.presentationMode {
            XCTAssert(true)
        }
        else {
            XCTAssert(false)
        }
    }
    
    func test_setPresentationModeModal() {
        
        let wireframe = MockWireframe(application: UIApplication.shared)
        wireframe.setPresentationMode(from: [ModuleConstants.UrlParameter.presentationMode: "modal"])
        
        if case .modal = wireframe.presentationMode {
            XCTAssert(true)
        }
        else {
            XCTAssert(false)
        }
    }
}

class MockWireframe: WireframeType {
    
    var application: UIApplication
    var injectedRootVc: UIViewController?
    internal var tempRootVc: UIViewController?
    
    init(application: UIApplication, rootVc: UIViewController? = nil) {
        self.application = application
        self.injectedRootVc = rootVc
    }
    
    let bundle = Bundle(for: WireframeTypeTests.self)
    lazy var storyboard: UIStoryboard = UIStoryboard(name: "TestStoryboard", bundle: bundle)
    var presentedViewControllers = [WeakContainer<UIViewController>]()
    var presentationMode: ModulePresentationMode = .none
}
