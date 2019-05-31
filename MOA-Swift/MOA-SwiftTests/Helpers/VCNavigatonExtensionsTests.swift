//
//  VCNavigatonExtensionsTests.swift
//  MOA-SwiftTests
//
//  Created by Mladen Despotovic on 30.05.19.
//  Copyright © 2019 Mladen Despotovic. All rights reserved.
//

import XCTest
import UIKit
@testable import MOA_Swift

class VCNavigatonExtensionsTests: XCTestCase {
    
    private var storyboard: UIStoryboard?
    
    override func setUp() {
        
        let bundle = Bundle(for: VCExtensionsTests.self)
        storyboard = UIStoryboard(name: "TestStoryboard", bundle: bundle)
    }
    
    override func tearDown() {
        storyboard = nil
    }

    func test_noRootViewController() {
        
        // Prepare
        let shared = UIApplication.shared
        let navigationExtension = MockVCNavigatonExtension(application: shared)
        
        // Execute and Test
        XCTAssertNil(navigationExtension.rootVc)
    }
    
    func test_rootViewController() {
        
        // Prepare
        let shared = UIApplication.shared
        var navigationExtension = MockVCNavigatonExtension(application: shared)
        let topVc = storyboard?.instantiateViewController(withIdentifier: "topVc")
        topVc?.view = MockViewWithKeyWindow()
        navigationExtension.rootVc = topVc
        
        // Execute and Test
        XCTAssertNotNil(navigationExtension.rootVc)
    }
    
    func test_rootViewController_topPresentedController() {
        
        // Prepare
        let shared = UIApplication.shared
        var navigationExtension = MockVCNavigatonExtension(application: shared)
        let topVc = storyboard?.instantiateViewController(withIdentifier: "topVc")
        topVc?.view = MockViewWithKeyWindow()
        navigationExtension.rootVc = topVc
        
        // Execute and Test
        XCTAssertEqual(navigationExtension.rootVc, navigationExtension.topPresentedController)
    }
    
    func test_topPresentedController_theSecondOne() {
        
        // Prepare
        let shared = UIApplication.shared
        var navigationExtension = MockVCNavigatonExtension(application: shared)
        
        let topVc = storyboard?.instantiateViewController(withIdentifier: "topPresentingVc") as! MockPresentingViewController
        topVc.view = MockViewWithKeyWindow()
        
        let containerVc = storyboard?.instantiateViewController(withIdentifier: "containerVc")
        containerVc?.view = MockViewWithSuperview(frame: CGRect(x: 1, y: 1, width: 1, height: 1),
                                                  superview: topVc.view)
        
        topVc.presentedVc = containerVc
        navigationExtension.rootVc = topVc
        
        // Execute and Test
        XCTAssertEqual(containerVc, navigationExtension.topPresentedController)
    }
    
    func test_topPresentedController_theSecondOne_passingRoot() {
        
        // Prepare
        let shared = UIApplication.shared
        var navigationExtension = MockVCNavigatonExtension(application: shared)
        
        let topVc = storyboard?.instantiateViewController(withIdentifier: "topPresentingVc") as! MockPresentingViewController
        topVc.view = MockViewWithKeyWindow()
        
        let containerVc = storyboard?.instantiateViewController(withIdentifier: "containerVc")
        containerVc?.view = MockViewWithSuperview(frame: CGRect(x: 1, y: 1, width: 1, height: 1),
                                                  superview: topVc.view)
        
        topVc.presentedVc = containerVc
        navigationExtension.rootVc = topVc
        
        // Execute
        let topPresented = navigationExtension.topPresentedController(viewController: topVc)
        
        // Execute and Test
        XCTAssertEqual(containerVc, topPresented)
    }
    
    func test_rootController_noTopNavigatedController() {
        
        // Prepare
        let shared = UIApplication.shared
        var navigationExtension = MockVCNavigatonExtension(application: shared)
        let topVc = storyboard?.instantiateViewController(withIdentifier: "topVc")
        topVc?.view = MockViewWithKeyWindow()
        navigationExtension.rootVc = topVc
        
        // Execute and Test
        XCTAssertNil(navigationExtension.topNavigatedController)
    }
    
    func test_navigationController_topNavigatedController() {
        
        // Prepare
        let shared = UIApplication.shared
        var navigationExtension = MockVCNavigatonExtension(application: shared)
        
        let containerVc = storyboard?.instantiateViewController(withIdentifier: "containerVc") as! MockContainerViewController
        containerVc.view = MockViewWithKeyWindow()
        let navVc = storyboard?.instantiateViewController(withIdentifier: "navController") as! MockNavigationViewController
        let presentedVc = storyboard?.instantiateViewController(withIdentifier: "topPresentingVc") as! MockPresentingViewController
        presentedVc.view = MockViewWithSuperview(frame: CGRect(x: 1, y: 1, width: 1, height: 1),
                                                 superview: containerVc.view)
        let tabVc = storyboard?.instantiateViewController(withIdentifier: "tabBarController") as! MockTabBarController
        
        navigationExtension.rootVc = tabVc
        navVc.pushViewController(presentedVc, animated: false)
        tabVc.setViewControllers([navVc], animated: false)

        
        // Execute and Test
        XCTAssertNotNil(navigationExtension.topNavigatedController)
    }
    
    func test_topViewController_navigatedController() {
        
        // Prepare
        let shared = UIApplication.shared
        var navigationExtension = MockVCNavigatonExtension(application: shared)
        
        let containerVc = storyboard?.instantiateViewController(withIdentifier: "containerVc") as! MockContainerViewController
        containerVc.view = MockViewWithKeyWindow()
        let navVc = storyboard?.instantiateViewController(withIdentifier: "navController") as! MockNavigationViewController
        let presentedVc = storyboard?.instantiateViewController(withIdentifier: "topPresentingVc") as! MockPresentingViewController
        presentedVc.view = MockViewWithSuperview(frame: CGRect(x: 1, y: 1, width: 1, height: 1),
                                                 superview: containerVc.view)
        let tabVc = storyboard?.instantiateViewController(withIdentifier: "tabBarController") as! MockTabBarController
        
        navigationExtension.rootVc = tabVc
        navVc.pushViewController(presentedVc, animated: false)
        tabVc.setViewControllers([navVc], animated: false)
        
        
        // Execute and Test
        XCTAssertEqual(navigationExtension.topViewController(baseVc: tabVc), presentedVc)
    }
    
    func test_topViewController_presentedController() {
        
        // Prepare
        let shared = UIApplication.shared
        var navigationExtension = MockVCNavigatonExtension(application: shared)
        
        let containerVc = storyboard?.instantiateViewController(withIdentifier: "containerVc") as! MockContainerViewController
        containerVc.view = MockViewWithKeyWindow()
        let navVc = storyboard?.instantiateViewController(withIdentifier: "navController") as! MockNavigationViewController
        let presentedVc = storyboard?.instantiateViewController(withIdentifier: "topPresentingVc") as! MockPresentingViewController
        presentedVc.view = MockViewWithSuperview(frame: CGRect(x: 1, y: 1, width: 1, height: 1),
                                                 superview: containerVc.view)
        let modallyPresentedVc = storyboard?.instantiateViewController(withIdentifier: "topPresentingVc") as! MockPresentingViewController
        modallyPresentedVc.view = MockViewWithSuperview(frame: CGRect(x: 1, y: 1, width: 1, height: 1),
                                                 superview: presentedVc.view)
        let tabVc = storyboard?.instantiateViewController(withIdentifier: "tabBarController") as! MockTabBarController
        
        navigationExtension.rootVc = tabVc
        navVc.pushViewController(presentedVc, animated: false)
        tabVc.setViewControllers([navVc], animated: false)
        presentedVc.presentedVc = modallyPresentedVc
        
        // Execute and Test
        XCTAssertEqual(navigationExtension.topViewController(baseVc: tabVc), modallyPresentedVc)
    }
}

class MockVCNavigatonExtension: VCNavigatonExtensions {
    
    var tempRootVc: UIViewController? = nil
    var application: UIApplication
    
    init(application: UIApplication) {
        self.application = application
    }
}
