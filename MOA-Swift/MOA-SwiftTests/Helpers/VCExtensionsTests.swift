//
//  VCExtensionsTests.swift
//  MOA-SwiftTests
//
//  Created by Mladen Despotovic on 31.03.19.
//  Copyright © 2019 Mladen Despotovic. All rights reserved.
//

import XCTest
@testable import MOA_Swift

class VCExtensionsTests: XCTestCase {
	
	private var storyboard: UIStoryboard?
	
    override func setUp() {
		
		let bundle = Bundle(for: VCExtensionsTests.self)
		storyboard = UIStoryboard(name: "TestStoryboard", bundle: bundle)
    }

    override func tearDown() {
        storyboard = nil
    }

	func test_windowKeyWindow() {
		
		let topVc = storyboard?.instantiateViewController(withIdentifier: "topVc")
		topVc?.view = MockViewWithKeyWindow()
		
		let containerVc = storyboard?.instantiateViewController(withIdentifier: "containerVc")
		containerVc?.view = MockViewWithSuperview(frame: CGRect(x: 1, y: 1, width: 1, height: 1),
                                                  superview: topVc!.view)

		let containerView = containerVc!.view
		XCTAssertNotNil(topVc?.window(for: containerView!))
	}
    
    func test_windowNoKeyWindow() {
        
        let topVc = storyboard?.instantiateViewController(withIdentifier: "topVc")
        topVc?.view = MockViewWithWindow()
        
        let containerVc = storyboard?.instantiateViewController(withIdentifier: "containerVc")
        containerVc?.view = MockViewWithSuperview(frame: CGRect(x: 1, y: 1, width: 1, height: 1),
                                                  superview: topVc!.view)
        
        let containerView = containerVc!.view
        XCTAssertNil(topVc?.window(for: containerView!))
    }
    
    func test_windowNoSuperview() {
        
        let topVc = storyboard?.instantiateViewController(withIdentifier: "topVc")
        XCTAssertNil(topVc?.window(for: topVc!.view))
    }
    
    func test_rootVcHasRoot() {
        
        let topVc = storyboard?.instantiateViewController(withIdentifier: "topVc")
        topVc?.view = MockViewWithKeyWindow()
        
        let containerVc = storyboard?.instantiateViewController(withIdentifier: "containerVc")
        containerVc?.view = MockViewWithSuperview(frame: CGRect(x: 1, y: 1, width: 1, height: 1),
                                                  superview: topVc!.view)

        let window = topVc!.view.superview as! UIWindow
        window.rootViewController = topVc

        XCTAssertNotNil(containerVc?.rootVc())
    }
    
    func test_rootVcNoRoot() {
        
        let topVc = storyboard?.instantiateViewController(withIdentifier: "topVc")
        topVc?.view = MockViewWithKeyWindow()
        
        let containerVc = storyboard?.instantiateViewController(withIdentifier: "containerVc")
        containerVc?.view = MockViewWithSuperview(frame: CGRect(x: 1, y: 1, width: 1, height: 1),
                                                  superview: topVc!.view)
        
        XCTAssertNil(containerVc?.rootVc())
    }
}

class MockTopViewController: StoryboardIdentifiableViewController {
	
}

class MockContainerViewController: StoryboardIdentifiableViewController {
	
}

class MockViewWithKeyWindow: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var storedWindow = MockKeyWindow()
	
	override var superview: UIView? {
		get {
			return storedWindow
		}
	}
}

class MockViewWithWindow: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var storedWindow = UIWindow(frame: CGRect(x: 1, y: 1, width: 1, height: 1))
    
    override var superview: UIView? {
        get {
            return storedWindow
        }
    }
}

class MockViewWithSuperview: UIView {
	
	override init(frame: CGRect) {
		super.init(frame: frame)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private var injectedSuperview: UIView?
	
	convenience init(frame: CGRect, superview: UIView) {
		self.init(frame: frame)
		self.injectedSuperview = superview
	}
	override var superview: UIView? {
		get {
			return injectedSuperview
		}
	}
}

class MockKeyWindow: UIWindow {
    
    override var isKeyWindow: Bool {
        get {
            return true
        }
    }
}





//var storyboard = UIStoryboard(name: "Main", bundle: nil)
//var controller = storyboard.instantiateViewControllerWithIdentifier("contentViewController") as UINavigationController
//controller.viewDidLoad()
