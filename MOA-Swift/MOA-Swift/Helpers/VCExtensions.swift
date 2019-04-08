//
//  VCExtensions.swift
//  ModuleArchitectureDemo
//
//  Created by Mladen Despotovic on 22/05/2018.
//  Copyright © 2018 Mladen Despotovic. All rights reserved.
//

import Foundation
import UIKit

internal extension UIViewController {
    
    func topPresentedController() -> UIViewController? {
        
        var topViewController = self.rootVc()
        while let presentedViewController = topViewController?.presentedViewController {
            topViewController = presentedViewController
        }
        return self
    }
    
    /**
     Simplified function to get the topmost UINavigationController.
     This can be written in many ways and can reflect the actual app navigation specifics.
     */
    func topmostNavigationController() -> UINavigationController? {
        
        var topRootViewController = self
        while let presentedViewController = topRootViewController.presentedViewController{
            topRootViewController = presentedViewController
        }
        
        switch topRootViewController {
        case let navigationViewController as UINavigationController:
            return navigationViewController
        case let tabBarViewController as UITabBarController:
            return tabBarViewController.selectedViewController as? UINavigationController
        default:
            return nil
        }
    }
	
	func rootVc() -> UIViewController? {
		
		return self.window(for: self.view)?.rootViewController
	}
	
	func window(for view: UIView) -> UIWindow? {
		
		if let superview = view.superview as? UIWindow,
            superview.isKeyWindow == true {
			return superview
		}
		else if let view = view.superview {
			return window(for: view)
		}
		else {
			return nil
		}
	}
}

